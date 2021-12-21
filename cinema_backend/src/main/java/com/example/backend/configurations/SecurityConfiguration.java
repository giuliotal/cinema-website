package com.example.backend.configurations;


import com.example.backend.support.authentication.*;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.convert.converter.Converter;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.oauth2.jwt.Jwt;

@Configuration
@EnableWebSecurity
@EnableGlobalMethodSecurity(prePostEnabled = true)
public class SecurityConfiguration extends WebSecurityConfigurerAdapter {


    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.cors().and().csrf().disable().sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS).and().authorizeRequests()
                .antMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                .antMatchers("/events/**").permitAll()
                .antMatchers("/users/**").permitAll()
                .antMatchers("/schedule/**").permitAll()
                .anyRequest().authenticated().and().oauth2ResourceServer().jwt().jwtAuthenticationConverter(authenticationConverter());
    }

    // necessario per far affidare a Spring la creazione dell'oggetto JwtAuthenticationConverter
    // e quindi la gestione delle annotazioni al suo interno (ovvero @Value che altrimenti non verrebbe valutata)
    @Bean
    public Converter<Jwt, AbstractAuthenticationToken> authenticationConverter() {
        return new JwtAuthenticationConverter();
    }

}