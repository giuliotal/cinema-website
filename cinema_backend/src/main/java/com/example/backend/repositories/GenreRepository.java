package com.example.backend.repositories;


import com.example.backend.entities.Genre;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface GenreRepository extends JpaRepository<Genre, Integer> {
    boolean existsByName(String name);
    Genre findGenreByName(String name);
}
