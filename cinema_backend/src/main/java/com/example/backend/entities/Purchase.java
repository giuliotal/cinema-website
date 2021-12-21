package com.example.backend.entities;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Getter
@Setter
@ToString
@EqualsAndHashCode
@Entity
@Table(name = "purchase")
public class Purchase {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;

    @Column(name = "purchase_time")
    @JsonFormat(pattern = "dd-MM-yyyy HH:mm")
    private LocalDateTime purchaseTime;

    @Column(name = "total_price")
    private Double totalPrice;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne(cascade = CascadeType.MERGE)
    @EqualsAndHashCode.Exclude
    @ToString.Exclude
    private ScheduledShow scheduledShow;

    @OneToMany(mappedBy = "purchase", cascade = CascadeType.ALL)
    private List<OrderedSeat> orderedSeatList;

    public void addOrderedSeat(OrderedSeat orderedSeat) {
        orderedSeatList.add(orderedSeat);
        orderedSeat.setPurchase(this);
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(scheduledShow.getEvent().getTitle());
        sb.append("\n");
        sb.append(scheduledShow.getStartDateTime().format(DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm")));
        sb.append("\n");
        sb.append("Ordered seats: " );
        sb.append(orderedSeatList.toString(), 1, orderedSeatList.toString().length()-1);
        sb.append("\n");
        sb.append("SALA ").append(scheduledShow.getRoom().getName());
        return sb.toString();
    }
}
