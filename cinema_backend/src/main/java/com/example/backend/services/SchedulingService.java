package com.example.backend.services;

import com.example.backend.entities.Event;
import com.example.backend.entities.OrderedSeat;
import com.example.backend.entities.Room;
import com.example.backend.entities.ScheduledShow;
import com.example.backend.repositories.EventRepository;
import com.example.backend.repositories.RoomRepository;
import com.example.backend.repositories.ScheduledShowRepository;
import com.example.backend.support.exceptions.EventNotFoundException;
import com.example.backend.support.exceptions.RoomNotFoundException;
import com.example.backend.support.exceptions.RoomReservedException;
import com.example.backend.support.exceptions.ScheduledShowNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;

@Service
public class SchedulingService {

    private final RoomRepository roomRepository;
    private final ScheduledShowRepository scheduledShowRepository;
    private final EventRepository eventRepository;

    @Autowired
    public SchedulingService(RoomRepository roomRepository, ScheduledShowRepository scheduledShowRepository, EventRepository eventRepository) {
        this.roomRepository = roomRepository;
        this.scheduledShowRepository = scheduledShowRepository;
        this.eventRepository = eventRepository;
    }

    @Transactional
    public ScheduledShow addScheduledShow(ScheduledShow scheduledShow, int eventId, int roomId) throws EventNotFoundException, RoomNotFoundException, RoomReservedException {
        if(!eventRepository.existsById(eventId))
            throw new EventNotFoundException();
        if(!roomRepository.existsById(roomId))
            throw new RoomNotFoundException();

        Event event = eventRepository.findById(eventId);
        Room room = roomRepository.findById(roomId);

        // imposto il termine dell'evento in base alla sua durata
        LocalDateTime endDateTime = scheduledShow.getStartDateTime().plusMinutes(event.getDuration());
        scheduledShow.setEndDateTime(endDateTime);

        //verifico che non ci siano altri eventi prenotati nella stessa fascia oraria e nella stessa sala
        List<ScheduledShow> conflictingScheduledShows = scheduledShowRepository.findConflictingSchedules(room, scheduledShow.getStartDateTime(), endDateTime);
        if(conflictingScheduledShows.size() > 0) throw new RoomReservedException();
        scheduledShow.setAvailableSeats(room.getTotalSeats());

        room.addSchedule(scheduledShow);
        event.addSchedule(scheduledShow);

        return scheduledShowRepository.save(scheduledShow);

    }

    @Transactional(readOnly = true)
    public List<ScheduledShow> showAllShows() {
        return scheduledShowRepository.findAll();
    }

    @Transactional(readOnly = true)
    public List<ScheduledShow> findShowsByRoomIdAndDate(int id, LocalDate date) throws RoomNotFoundException {
        if(!roomRepository.existsById(id))
            throw new RoomNotFoundException();
        LocalDateTime startDateTime = date.atTime(0,0);
        LocalDateTime endDateTime = date.atTime(23,59);
        return scheduledShowRepository.findAllByRoomIdAndDate(id,startDateTime, endDateTime);
    }

    @Transactional(readOnly = true)
    public List<ScheduledShow> findShowsByEventAndDate(int eventId, LocalDate date) {
        LocalDateTime startDateTime = date.atTime(0,0);
        LocalDateTime endDateTime = date.atTime(23,59);
        return scheduledShowRepository.findAllByEventIdAndDate(eventId, startDateTime, endDateTime);
    }

    public ScheduledShow findScheduledShowById(int id) throws ScheduledShowNotFoundException {
        if(!scheduledShowRepository.existsById(id))
            throw new ScheduledShowNotFoundException();
        return scheduledShowRepository.findScheduledShowById(id);
    }

    @Transactional(readOnly = true)
    public Set<OrderedSeat> showAllBookedSeats(int scheduleId) throws ScheduledShowNotFoundException {
        if(!scheduledShowRepository.existsById(scheduleId))
            throw new ScheduledShowNotFoundException();
        return scheduledShowRepository.findScheduledShowById(scheduleId).getOrderedSeatSet();
    }

}
