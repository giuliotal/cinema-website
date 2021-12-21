package com.example.backend.entities;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;
import java.util.*;

@Getter
@Setter
@EqualsAndHashCode
@ToString
@Entity
@Table(name = "genre")
public class Genre {

    @Id
    @JsonIgnore
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", nullable = false, updatable = false)
    private Integer id;

    @Column(name = "name", nullable = false)
    private String name;

    @EqualsAndHashCode.Exclude
    @ManyToMany(mappedBy = "genreSet", cascade = CascadeType.ALL)
    @JsonIgnore
    private Set<Event> eventSet = new HashSet<>();

}
