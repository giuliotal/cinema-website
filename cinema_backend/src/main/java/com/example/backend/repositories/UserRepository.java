package com.example.backend.repositories;


import com.example.backend.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User,Integer> {

    boolean existsByEmail(String email);
    User findUserByEmail(String email);
    User findUserById(int id);
    void deleteByEmail(String email);

}
