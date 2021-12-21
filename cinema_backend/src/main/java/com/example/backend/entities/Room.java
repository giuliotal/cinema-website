package com.example.backend.entities;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;
import java.util.LinkedList;
import java.util.List;

@Getter
@Setter
@EqualsAndHashCode
@ToString
@Entity
@Table(name = "room")
public class Room {

    @Id
    @Column(name = "id", updatable = false)
    private Integer id;

    @Column(name = "name")
    private String name;

    @Column(name = "total_seats")
    private Integer totalSeats;

    @Column(name = "row_seats")
    private Integer rowSeats;

    @EqualsAndHashCode.Exclude
    @ToString.Exclude
    @OneToMany(mappedBy = "room", cascade = CascadeType.ALL)
    @JsonIgnore
    private List<ScheduledShow> scheduledShowList = new LinkedList<>();

    public void addSchedule(ScheduledShow scheduledShow) {
        scheduledShowList.add(scheduledShow);
        scheduledShow.setRoom(this);
    }

    public void removeSchedule(ScheduledShow scheduledShow) {
        scheduledShowList.remove(scheduledShow);
        scheduledShow.setRoom(null);
    }
}
