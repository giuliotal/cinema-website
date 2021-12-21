package com.example.backend.controllers;


import com.example.backend.entities.User;
import com.example.backend.services.AccountingService;
import com.example.backend.support.exceptions.UserAlreadyExistsException;
import com.example.backend.support.exceptions.UserNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/users")
public class AccountingController {

    private final AccountingService accountingService;

    @Autowired
    public AccountingController(AccountingService accountingService) {
        this.accountingService = accountingService;
    }

    @PostMapping("/create")
    @PreAuthorize("permitAll()")
    public ResponseEntity<String> create(@RequestParam(value = "password") String password,
                                 @RequestParam(value = "role") String role,
                                 @RequestBody User user) {
        try {
            accountingService.addUser(user, role, password);
            return new ResponseEntity<>("User successfully added!", HttpStatus.OK);
        } catch (UserAlreadyExistsException e) {
            return new ResponseEntity<>("User already exists!", HttpStatus.BAD_REQUEST);
        }
    }

    @DeleteMapping("/remove")
    public ResponseEntity<String> remove(@RequestBody User user) {
        try {
            accountingService.removeUser(user);
        } catch (UserNotFoundException e) {
            return new ResponseEntity<>("Selected user doesn't exist!", HttpStatus.NOT_FOUND);
        }
        return new ResponseEntity<>("User successfully removed!", HttpStatus.OK);
    }

    @GetMapping("/all")
    @PreAuthorize("hasAuthority('admin')")
    public ResponseEntity<List<User>> getAll() {
        List<User> users = accountingService.showAllUsers();
        return new ResponseEntity<>(users, HttpStatus.OK);
    }

    @GetMapping("/search_by_email")
    // N.B. per questioni di sicurezza un utente richiedere solo le informazioni legate al proprio account
    // (ovvero solo l'oggetto utente corrispondente a se stesso)
    @PreAuthorize("#email == authentication.principal.getClaim('email')")
    public ResponseEntity getByEmail(@RequestParam(value = "email") String email) {
        try {
            User user = accountingService.showByEmail(email);
            return new ResponseEntity(user, HttpStatus.OK);
        } catch (UserNotFoundException e) {
           return new ResponseEntity("User not found", HttpStatus.NOT_FOUND);
        }

    }
}
