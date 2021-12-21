package com.example.backend.entities;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;
import java.time.LocalDateTime;
import java.util.Set;

@Getter
@Setter
@EqualsAndHashCode
@ToString
@Entity
@Table(name = "scheduled_show")
public class ScheduledShow {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;

    @Column(name = "start_date_time", nullable = false)
    @JsonFormat(pattern = "dd-MM-yyyy HH:mm")
    private LocalDateTime startDateTime;

    @Column(name = "end_date_time", nullable = false)
    @JsonFormat(pattern = "dd-MM-yyyy HH:mm")
    private LocalDateTime endDateTime;

    @ManyToOne
    @JoinColumn(name = "event_id")
    private Event event;

    @ManyToOne
    @JoinColumn(name = "room_id")
    private Room room;

    @Column(name = "available_seats")
    private Integer availableSeats;

    @OneToMany(mappedBy = "scheduledShow")
    @EqualsAndHashCode.Exclude
    @ToString.Exclude
    private Set<OrderedSeat> orderedSeatSet;

    public void addOrderedSeat(OrderedSeat orderedSeat) {
        orderedSeatSet.add(orderedSeat);
        orderedSeat.setScheduledShow(this);
    }

}