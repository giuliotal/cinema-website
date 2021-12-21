package com.example.backend.entities;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Getter
@Setter
@EqualsAndHashCode
@ToString
@Entity
@Table(name = "event")
public class Event {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", nullable = false, updatable = false)
    private Integer id;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "duration")
    private Integer duration;

    @Column(name = "price")
    private Double price;

    @Column(name = "description")
    private String description;

    @Column(name = "content_rating")
    private String contentRating;

    @EqualsAndHashCode.Exclude
    @ToString.Exclude
    @OneToMany(mappedBy = "event", cascade = CascadeType.ALL)
    @JsonIgnore
    private List<ScheduledShow> scheduledShowList;

    @EqualsAndHashCode.Exclude
    // alla rimozione di un evento rimangono i suoi generi nella tabella Genre
    @ManyToMany(cascade = CascadeType.DETACH)
    @JoinTable(
            name = "genre_definition",
            joinColumns = {@JoinColumn(name = "event_id")},
            inverseJoinColumns = {@JoinColumn(name = "genre_id")}
    )
    private Set<Genre> genreSet = new HashSet<>();

    public void addGenre(Genre genre) {
        genreSet.add(genre);
        genre.getEventSet().add(this);
    }

    public void addSchedule(ScheduledShow scheduledShow) {
        scheduledShowList.add(scheduledShow);
        scheduledShow.setEvent(this);
    }

}
