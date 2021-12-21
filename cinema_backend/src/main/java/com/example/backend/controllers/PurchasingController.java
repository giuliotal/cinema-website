package com.example.backend.controllers;


import com.example.backend.entities.Purchase;
import com.example.backend.entities.User;
import com.example.backend.services.PurchasingService;
import com.example.backend.support.exceptions.DateWrongRangeException;
import com.example.backend.support.exceptions.SeatAlreadyBookedException;
import com.example.backend.support.exceptions.SeatsUnavailableException;
import com.example.backend.support.exceptions.UserNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/purchase")
public class PurchasingController {

    private final PurchasingService purchasingService;

    @Autowired
    public PurchasingController(PurchasingService purchasingService) {
        this.purchasingService = purchasingService;
    }

    @PostMapping
    @PreAuthorize("hasAuthority('user')")
    public ResponseEntity<String> createPurchase(@RequestBody Purchase purchase) {
        try {
            Purchase p = purchasingService.addPurchase(purchase);
            return new ResponseEntity<>("Purchase confirmed. Thanks.\n"+p.toString(), HttpStatus.OK);
        } catch (SeatsUnavailableException e) {
            return new ResponseEntity<>("The number of seats requested is not available.", HttpStatus.BAD_REQUEST);
        } catch (SeatAlreadyBookedException e) {
            return new ResponseEntity<>("The seats you have chosen have already been booked.", HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/history")
    @PreAuthorize("hasAuthority('user')")
    public ResponseEntity getAllByUser(@RequestParam(value = "pageNumber", defaultValue = "0") int pageNumber,
                                       @RequestParam(value = "pageSize", defaultValue = "10") int pageSize,
                                       @RequestParam(value = "sortBy", defaultValue = "id") String sortBy,
                                       @RequestParam(value = "order", defaultValue = "descending") String order,
                                       @RequestBody User user) {
        try {
            List<Purchase> purchases = purchasingService.getAllPurchasesByUser(user, pageNumber, pageSize, sortBy, order);
            return new ResponseEntity(purchases, HttpStatus.OK);
        } catch (UserNotFoundException e) {
            return new ResponseEntity("User not found!", HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/history_pages")
    @PreAuthorize("hasAuthority('user')")
    public ResponseEntity getTotalPagesNumber(@RequestParam(value = "pageSize", defaultValue = "10") int pageSize,
                                              @RequestBody User user) {
        try {
            int totalPages = purchasingService.getPurchasePagesNumber(user, pageSize);
            return new ResponseEntity(totalPages, HttpStatus.OK);
        } catch (UserNotFoundException e) {
            return new ResponseEntity("User not found!", HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/search_by_date")
    @PreAuthorize("hasAuthority('user')")
    public ResponseEntity getByPeriod(@RequestParam(value = "start_date") @DateTimeFormat(pattern = "dd-MM-yyyy") LocalDate startDate,
                                      @RequestParam(value = "end_date", required = false) @DateTimeFormat(pattern = "dd-MM-yyyy") LocalDate endDate,
                                      @RequestBody User user) {
        try {
            List<Purchase> result = purchasingService.getPurchasesByUserInPeriod(startDate, endDate, user);
            return new ResponseEntity<>(result, HttpStatus.OK);
        } catch (UserNotFoundException e) {
            return new ResponseEntity("User not found!", HttpStatus.BAD_REQUEST);
        } catch (DateWrongRangeException e) {
            return new ResponseEntity("Start date must be previous end date!", HttpStatus.BAD_REQUEST);
        }
    }


}
