package com.example.backend.entities;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;

@Getter
@Setter
@EqualsAndHashCode
@ToString
@Entity
@Table(name = "ordered_seat")
// rappresenta un singolo biglietto
public class OrderedSeat {

    @Id
    @Column(name = "id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "seat_number")
    private Integer seatNumber;

    @ManyToOne(cascade = CascadeType.ALL)
    @JsonIgnore
    @EqualsAndHashCode.Exclude
    @ToString.Exclude
    @JoinColumn(name = "purchase_id")
    private Purchase purchase;

    @ManyToOne(cascade = CascadeType.DETACH) //all'eliminazione di un posto lo show deve rimanere
    @JsonIgnore
    @EqualsAndHashCode.Exclude
    @ToString.Exclude
    private ScheduledShow scheduledShow;

    @Override
    public String toString() {
        return "n°"+seatNumber;
    }

}
