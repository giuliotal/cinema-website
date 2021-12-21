package com.example.backend.controllers;


import com.example.backend.entities.OrderedSeat;
import com.example.backend.entities.ScheduledShow;
import com.example.backend.services.SchedulingService;
import com.example.backend.support.exceptions.EventNotFoundException;
import com.example.backend.support.exceptions.RoomNotFoundException;
import com.example.backend.support.exceptions.RoomReservedException;
import com.example.backend.support.exceptions.ScheduledShowNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Set;

@RestController
@RequestMapping("/schedule")
public class SchedulingController {

    private final SchedulingService schedulingService;

    @Autowired
    public SchedulingController(SchedulingService schedulingService) {
        this.schedulingService = schedulingService;
    }

    @PreAuthorize("hasAuthority('admin')")
    @PostMapping
    public ResponseEntity schedule(@RequestBody ScheduledShow scheduledShow,
                                   @RequestParam(value = "eventId") int eventId,
                                   @RequestParam(value = "roomId") int roomId) {
        try {
            schedulingService.addScheduledShow(scheduledShow, eventId, roomId);
        } catch (EventNotFoundException e) {
            return new ResponseEntity<>("Selected event doesn't exist!", HttpStatus.NOT_FOUND);
        } catch (RoomNotFoundException re) {
            return new ResponseEntity<>("Selected room doesn't exist!", HttpStatus.NOT_FOUND);
        } catch (RoomReservedException e) {
            return new ResponseEntity<>("Room already reserved. Choose a different time schedule", HttpStatus.BAD_REQUEST);
        }
        return new ResponseEntity<>("Schedule successfully added!", HttpStatus.OK);
    }

    @PreAuthorize("hasAuthority('admin')")
    @GetMapping("/all")
    public ResponseEntity<List<ScheduledShow>> getAllScheduledShows() {
        List<ScheduledShow> scheduledShowList = schedulingService.showAllShows();
        return new ResponseEntity<>(scheduledShowList, HttpStatus.OK);
    }

    @PreAuthorize("hasAuthority('admin')")
    @GetMapping("/search_by_room/{roomId}/{date}")
    public ResponseEntity getScheduledShowsByRoomAndDate(@PathVariable(value = "roomId") int roomId,
                                                         @PathVariable(value = "date") @DateTimeFormat(pattern = "dd-MM-yyyy") LocalDate date) {
        try {
            List<ScheduledShow> scheduledShowList = schedulingService.findShowsByRoomIdAndDate(roomId,date);
            return new ResponseEntity<>(scheduledShowList, HttpStatus.OK);
        }catch (RoomNotFoundException e) {
            return new ResponseEntity<>("Selected room doesn't exist!", HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("search_all/{eventId}/{date}")
    public ResponseEntity getScheduledShowsByEventAndDate(@PathVariable(value = "eventId") int eventId,
                                                          @PathVariable(value = "date") @DateTimeFormat(pattern = "dd-MM-yyyy") LocalDate date) {
        List<ScheduledShow> scheduledShowList = schedulingService.findShowsByEventAndDate(eventId, date);
        return new ResponseEntity<>(scheduledShowList, HttpStatus.OK);
    }

    @GetMapping("search_by_id/{scheduledShowId}")
    public ResponseEntity getScheduledShowById(@PathVariable(value = "scheduledShowId") int id) {
        try {
            ScheduledShow scheduledShow = schedulingService.findScheduledShowById(id);
            return new ResponseEntity<>(scheduledShow, HttpStatus.OK);
        }catch(ScheduledShowNotFoundException e){
            return new ResponseEntity<>("Selected show not found", HttpStatus.NOT_FOUND);
        }
    }

    @PreAuthorize("hasAuthority('admin')")
    @GetMapping("/show_booked_seats/{scheduledShowId}")
    public ResponseEntity getAllBookedSeatsPerShow(@PathVariable int scheduledShowId) {
        try {
            Set<OrderedSeat> seats = schedulingService.showAllBookedSeats(scheduledShowId);
            return new ResponseEntity(seats, HttpStatus.OK);
        }catch (ScheduledShowNotFoundException e) {
            return new ResponseEntity<>("Selected schedule doesn't exist!", HttpStatus.BAD_REQUEST);
        }
    }

}
