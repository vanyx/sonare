package com.sonare.spring.model;

import jakarta.persistence.*;

import lombok.Getter;
import lombok.Setter;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.type.SqlTypes;
import org.locationtech.jts.geom.Point;

import java.time.LocalDateTime;

@Setter
@Getter
@Entity
@Table(name = "police", indexes = {
        @Index(name = "police_location_index", columnList = "location", unique = false)
})
public class Police {

    // Getters et setters
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // PRIMARY KEY, AUTO GENERATED
    private long id;

    @JdbcTypeCode(SqlTypes.GEOMETRY)
    private Point location;

    @CreationTimestamp  // AUTO GENERATED
    @Column(updatable = false)
    private LocalDateTime createdAt; // 'created_at' dans la DB

    @UpdateTimestamp  // AUTO GENERATED
    private LocalDateTime updatedAt; // 'updated_at' dans la DB

    // le setter automatique de lombok ne fonctionne pas avec le point
    public void setLocation(Point location) {
        this.location = location;
    }
}
