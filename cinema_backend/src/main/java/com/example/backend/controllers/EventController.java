package com.example.backend.controllers;


import com.example.backend.entities.Event;
import com.example.backend.services.EventService;
import com.example.backend.support.exceptions.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Set;

@RestController
@RequestMapping("/events")
public class EventController {

    private final EventService eventService;

    @Autowired
    public EventController(EventService eventService) {
        this.eventService = eventService;;
    }

    @PostMapping("/create")
    public ResponseEntity<String> create(@RequestBody Event event) {
        try {
            eventService.addEvent(event);
            return new ResponseEntity<>("Event successfully added!", HttpStatus.OK);
        } catch (EventAlreadyExistsException e) {
            return new ResponseEntity<>("Event already exists!", HttpStatus.BAD_REQUEST);
        }
    }

    @DeleteMapping("/delete")
    public ResponseEntity<String> delete(@RequestBody Event event) {
        try {
            eventService.removeEvent(event);
            return new ResponseEntity<>("Event successfully removed!", HttpStatus.OK);
        } catch (EventNotFoundException e) {
            return new ResponseEntity<>("Selected event doesn't exist!", HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/all")
    public ResponseEntity<List<Event>> getAllEvents() {
        List<Event> events = eventService.showAllEvents();
        // N.B. in ogni caso restituisco una lista: nel caso in cui non ci sono eventi è una lista vuota
        return new ResponseEntity<>(events, HttpStatus.OK);
    }

    @GetMapping("/on_screen")
    public ResponseEntity<List<Event>> getOnScreenEvents() {
        List<Event> events = eventService.showOnScreenEvents();
        return new ResponseEntity<>(events, HttpStatus.OK);
    }

    @GetMapping("/coming_soon")
    public ResponseEntity<List<Event>> getComingSoonEvents() {
        List<Event> events = eventService.showComingSoonEvents();
        return new ResponseEntity<>(events, HttpStatus.OK);
    }

    @GetMapping("/search/by_date")
    public ResponseEntity getByDate(@RequestParam(value = "date") @DateTimeFormat(pattern = "dd-MM-yyyy") LocalDate date) {
        List<Event> events = eventService.showEventsByDate(date);
        return new ResponseEntity<>(events, HttpStatus.OK);
    }


    @GetMapping("search/by_title")
    public ResponseEntity getByTitle(@RequestParam String title){
        List<Event> events = eventService.showEventsByTitle(title);
        return new ResponseEntity<>(events, HttpStatus.OK);
    }

    @PutMapping("/define_genre")
    public ResponseEntity<String> defineGenre(@RequestParam(value = "eventId") int eventId,
                                                       @RequestParam(value = "genreName") String genreName) {
        try {
            eventService.addGenre(eventId, genreName);
            return new ResponseEntity<>("Genre successfully added!", HttpStatus.OK);
        } catch (InvalidGenreException e) {
            return new ResponseEntity<>("Invalid genre!", HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/search/by_genre/{genreName}")
    public ResponseEntity getByGenre(@PathVariable("genreName") String genreName) {
        Set<Event> events = eventService.showFilmsByGenre(genreName);
        return new ResponseEntity(events, HttpStatus.OK);
    }

}
