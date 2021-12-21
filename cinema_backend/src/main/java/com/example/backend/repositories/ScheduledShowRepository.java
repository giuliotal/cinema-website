package com.example.backend.repositories;


import com.example.backend.entities.Room;
import com.example.backend.entities.ScheduledShow;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import javax.persistence.LockModeType;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ScheduledShowRepository extends JpaRepository<ScheduledShow, Integer> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    ScheduledShow findScheduledShowById(int id);

    @Query("select s from Room r, ScheduledShow s where r.id = :roomId and r = s.room and s.startDateTime >= :start and s.startDateTime <= :end")
    List<ScheduledShow> findAllByRoomIdAndDate(int roomId, LocalDateTime start, LocalDateTime end);

    @Query("select s from Event e, ScheduledShow s where e.id = :eventId and e = s.event and s.startDateTime >= :start and s.startDateTime <= :end")
    List<ScheduledShow> findAllByEventIdAndDate(int eventId, LocalDateTime start, LocalDateTime end);

    @Query("select s from ScheduledShow s where s.room = :room and :endDateTime >= s.startDateTime and :startDateTime <= s.endDateTime")
    List<ScheduledShow> findConflictingSchedules(@Param(value = "room") Room room,
                                                 @Param(value = "startDateTime") LocalDateTime startDateTime,
                                                 @Param(value = "endDateTime") LocalDateTime endDateTime);
}
