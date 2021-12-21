package com.example.backend.repositories;


import com.example.backend.entities.OrderedSeat;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface OrderedSeatRepository extends JpaRepository<OrderedSeat,Integer> {
    boolean existsByScheduledShowIdAndSeatNumber(int scheduledShowId, int seatNumber);
}
