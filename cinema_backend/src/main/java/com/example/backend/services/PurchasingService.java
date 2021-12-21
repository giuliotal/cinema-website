package com.example.backend.services;

import com.example.backend.entities.OrderedSeat;
import com.example.backend.entities.Purchase;
import com.example.backend.entities.ScheduledShow;
import com.example.backend.entities.User;
import com.example.backend.repositories.OrderedSeatRepository;
import com.example.backend.repositories.PurchaseRepository;
import com.example.backend.repositories.ScheduledShowRepository;
import com.example.backend.repositories.UserRepository;
import com.example.backend.support.exceptions.DateWrongRangeException;
import com.example.backend.support.exceptions.SeatAlreadyBookedException;
import com.example.backend.support.exceptions.SeatsUnavailableException;
import com.example.backend.support.exceptions.UserNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class PurchasingService {

    private final PurchaseRepository purchaseRepository;
    private final OrderedSeatRepository orderedSeatRepository;
    private final UserRepository userRepository;
    private final ScheduledShowRepository scheduledShowRepository;

    @Autowired
    public PurchasingService(PurchaseRepository purchaseRepository, OrderedSeatRepository orderedSeatRepository, UserRepository userRepository, ScheduledShowRepository scheduledShowRepository) {
        this.purchaseRepository = purchaseRepository;
        this.orderedSeatRepository = orderedSeatRepository;
        this.userRepository = userRepository;
        this.scheduledShowRepository = scheduledShowRepository;
    }

    // con livello di isolamento SERIALIZABLE bloccherei l'intera tabella degli show ad ogni acquisto
    @Transactional
    public Purchase addPurchase(Purchase purchase) throws SeatsUnavailableException, SeatAlreadyBookedException {

        purchase.setPurchaseTime(LocalDateTime.now());
        // utilizzo lock pessimistico sul singolo show (riga della tabella "scheduled_show": in questo modo possono
        // essere effettuati altri acquisti per altri show in maniera concorrente
        ScheduledShow scheduledShow = scheduledShowRepository.findScheduledShowById(purchase.getScheduledShow().getId());

        for (OrderedSeat o : purchase.getOrderedSeatList()) {

            // 1. Controllo se ci sono ancora posti disponibili
            int newSeats = scheduledShow.getAvailableSeats() - 1;
            if ( newSeats < 0 ) {
                throw new SeatsUnavailableException();
            }
            // 2. Controllo se i posti selezionati sono ancora disponibili
            if(orderedSeatRepository.existsByScheduledShowIdAndSeatNumber(scheduledShow.getId(), o.getSeatNumber()))
                throw new SeatAlreadyBookedException();

            o.setPurchase(purchase); //relazione bidirezionale: gli orderedSeat dal lato dell'entità purchase vengono impostati dal client
            scheduledShow.addOrderedSeat(o);
            scheduledShow.setAvailableSeats(newSeats);
        }

        return purchaseRepository.save(purchase);
    }

    @Transactional(readOnly = true)
    public List<Purchase> getAllPurchasesByUser(User user, int pageNumber, int pageSize, String sortBy, String order) throws UserNotFoundException {
        if ( !userRepository.existsById(user.getId()) ) {
            throw new UserNotFoundException();
        }
        Pageable paging;
        if(order.equals("descending")) {
            paging = PageRequest.of(pageNumber, pageSize, Sort.by(sortBy).descending());
        }
        else {
            paging = PageRequest.of(pageNumber, pageSize, Sort.by(sortBy).ascending());
        }
        Page<Purchase> pagedResult = purchaseRepository.findAllByUser(user, paging);
        return pagedResult.getContent();
    }

    @Transactional(readOnly = true)
    public int getPurchasePagesNumber(User user, int pageSize) throws UserNotFoundException {
        if ( !userRepository.existsById(user.getId()) ) {
            throw new UserNotFoundException();
        }
        Pageable paging = PageRequest.of(0, pageSize);
        Page<Purchase> pagedResult = purchaseRepository.findAllByUser(user, paging);
        return pagedResult.getTotalPages();
    }

    @Transactional(readOnly = true)
    public List<Purchase> getPurchasesByUserInPeriod(LocalDate startDate, LocalDate endDate, User user) throws UserNotFoundException, DateWrongRangeException {
        if ( !userRepository.existsById(user.getId()) ) {
            throw new UserNotFoundException();
        }
        if ( startDate.compareTo(endDate) >= 0 ) {
            throw new DateWrongRangeException();
        }
        return purchaseRepository.findByUserInPeriod(startDate.atTime(0,0), endDate.atTime(23,59), user);
    }

}
