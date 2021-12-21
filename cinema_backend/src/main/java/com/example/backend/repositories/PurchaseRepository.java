package com.example.backend.repositories;


import com.example.backend.entities.Purchase;
import com.example.backend.entities.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Calendar;
import java.util.List;

@Repository
public interface PurchaseRepository extends JpaRepository<Purchase,Integer> {

    @Query("select p from Purchase p where p.purchaseTime > ?1 and p.purchaseTime < ?2 and p.user = ?3")
    List<Purchase> findByUserInPeriod(LocalDateTime startDate, LocalDateTime endDate, User user);

    Page<Purchase> findAllByUser(User user, Pageable pageable);

}
