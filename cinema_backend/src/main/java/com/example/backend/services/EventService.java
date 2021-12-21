package com.example.backend.services;


import com.example.backend.entities.*;
import com.example.backend.repositories.EventRepository;
import com.example.backend.repositories.GenreRepository;
import com.example.backend.repositories.RoomRepository;
import com.example.backend.repositories.ScheduledShowRepository;
import com.example.backend.support.exceptions.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;

@Service
public class EventService {

    private final EventRepository eventRepository;
    private final ScheduledShowRepository scheduledShowRepository;
    private final RoomRepository roomRepository;
    private final GenreRepository genreRepository;

    @Autowired
    public EventService(EventRepository eventRepository, ScheduledShowRepository scheduledShowRepository, RoomRepository roomRepository, GenreRepository genreRepository) {
        this.eventRepository = eventRepository;
        this.scheduledShowRepository = scheduledShowRepository;
        this.roomRepository = roomRepository;
        this.genreRepository = genreRepository;
    }

    @Transactional
    public Event addEvent(Event event) throws EventAlreadyExistsException {
        if(eventRepository.existsByTitle(event.getTitle()))
            throw new EventAlreadyExistsException();

        return eventRepository.save(event);
    }

    @Transactional
    public void removeEvent(Event event) throws EventNotFoundException {
        if(!eventRepository.existsByTitle(event.getTitle()))
            throw new EventNotFoundException();

        eventRepository.deleteByTitle(event.getTitle());
    }

    @Transactional(readOnly = true)
    public List<Event> showAllEvents() {
        return eventRepository.findAll();
    }

    @Transactional(readOnly = true)
    public List<Event> showOnScreenEvents() { return eventRepository.findScheduledEvents(); }

    @Transactional(readOnly = true)
    public List<Event> showComingSoonEvents() { return eventRepository.findNonScheduledEvents(); }

    @Transactional(readOnly = true)
    public List<Event> showEventsByTitle(String title) {
        return eventRepository.findByTitleContaining(title);
    }

    @Transactional(readOnly = true)
    public List<Event> showEventsByDate(LocalDate date) {
        LocalDateTime startDateTime = date.atTime(0,0);
        LocalDateTime endDateTime = date.atTime(23,59);
        return eventRepository.findAllByDate(startDateTime, endDateTime);
    }

    @Transactional
    public void addGenre(int eventId, String genreName) throws InvalidGenreException {
        if(!genreRepository.existsByName(genreName))
            throw new InvalidGenreException();

        Genre genre = genreRepository.findGenreByName(genreName);
        Event event = eventRepository.findById(eventId);
        event.addGenre(genre);
        eventRepository.save(event);

    }

    @Transactional(readOnly = true)
    public Set<Event> showFilmsByGenre(String genreName) {
        Genre genre = genreRepository.findGenreByName(genreName);
        return genre.getEventSet();
    }

}
