package com.example.backend.repositories;


import com.example.backend.entities.Event;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface EventRepository extends JpaRepository<Event,Integer> {

    List<Event> findByTitleContaining(String title);
    boolean existsByTitle(String title);
    void deleteByTitle(String title);
    Event findById(int id);

    @Query("select distinct e from Event e, ScheduledShow s where e = s.event and s.startDateTime >= ?1 and s.startDateTime <= ?2")
    List<Event> findAllByDate(LocalDateTime startDate, LocalDateTime endDate);

    @Query("select distinct e from Event  e, ScheduledShow s where e = s.event")
    List<Event> findScheduledEvents();

    //gli eventi non ancora schedulati sono intesi come "coming soon"
    @Query("select e from Event e where not exists (select e from ScheduledShow s where s.event = e)")
    List<Event> findNonScheduledEvents();
}
