package com.example.backend.services;

import com.example.backend.entities.User;
import com.example.backend.repositories.UserRepository;
import com.example.backend.support.exceptions.UserAlreadyExistsException;
import com.example.backend.support.exceptions.UserNotFoundException;
import org.keycloak.OAuth2Constants;
import org.keycloak.admin.client.CreatedResponseUtil;
import org.keycloak.admin.client.Keycloak;
import org.keycloak.admin.client.KeycloakBuilder;
import org.keycloak.admin.client.resource.RealmResource;
import org.keycloak.admin.client.resource.UserResource;
import org.keycloak.admin.client.resource.UsersResource;
import org.keycloak.representations.idm.ClientRepresentation;
import org.keycloak.representations.idm.CredentialRepresentation;
import org.keycloak.representations.idm.RoleRepresentation;
import org.keycloak.representations.idm.UserRepresentation;

import javax.ws.rs.core.Response;
import java.util.Arrays;


import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class AccountingService {

    private final UserRepository userRepository;

    @Value("${auth.admin-username}")
    private String adminUsername;

    @Value("${auth.admin-password}")
    private String adminPassword;

    @Value("${keycloak.auth-server-url}")
    private String serverUrl;

    @Value("${keycloak.realm}")
    private String realm;

    @Value("${keycloak.resource}")
    private String clientId;

    @Value("${keycloak.credentials.secret}")
    private String clientSecret;

    public AccountingService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Transactional
    public void addUser(User user, String role, String password) throws UserAlreadyExistsException {
        if(userRepository.existsByEmail(user.getEmail()))
            throw new UserAlreadyExistsException();

        userRepository.save(user);

        Keycloak keycloak = KeycloakBuilder.builder()
                .serverUrl(serverUrl)
                .realm(realm)
                .grantType(OAuth2Constants.PASSWORD)
                .clientId(clientId)
                .clientSecret(clientSecret)
                .username(adminUsername)
                .password(adminPassword)
                .build();

        // Define user
        UserRepresentation userRepresentation = new UserRepresentation();
        userRepresentation.setUsername(user.getEmail());
        userRepresentation.setFirstName(user.getFirstName());
        userRepresentation.setLastName(user.getLastName());
        userRepresentation.setEmail(user.getEmail());
        userRepresentation.setEnabled(true);

        // Get realm
        RealmResource realmResource = keycloak.realm(realm);
        UsersResource usersResource = realmResource.users();

        // Create user (requires manage-users role)
        Response response = usersResource.create(userRepresentation);
        String userId = CreatedResponseUtil.getCreatedId(response);

        // Define password credential
        CredentialRepresentation passwordCred = new CredentialRepresentation();
        passwordCred.setTemporary(false);
        passwordCred.setType(CredentialRepresentation.PASSWORD);
        passwordCred.setValue(password);

        UserResource userResource = usersResource.get(userId);

        // Set password credential
        userResource.resetPassword(passwordCred);

        // Get client
        ClientRepresentation app1Client = realmResource.clients().findByClientId(clientId).get(0);

        // Get client level role (requires view-clients role)
        RoleRepresentation userClientRole = realmResource.clients().get(app1Client.getId()).roles().get(role).toRepresentation();

        // Assign client level role to user
        userResource.roles().clientLevel(app1Client.getId()).add(Arrays.asList(userClientRole));

        // Required user actions:
        // VERIFY_EMAIL, UPDATE_PROFILE, CONFIGURE_OTP, UPDATE_PASSWORD, TERMS_AND_CONDITIONS
        // usersResource.get(userId).executeActionsEmail(Arrays.asList("VERIFY_EMAIL"));

    }

    @Transactional
    public void removeUser(User user) throws UserNotFoundException {
        if(!userRepository.existsByEmail(user.getEmail()))
            throw new UserNotFoundException();

        userRepository.deleteByEmail(user.getEmail());

        Keycloak keycloak = KeycloakBuilder.builder()
                .serverUrl(serverUrl)
                .realm(realm)
                .grantType(OAuth2Constants.PASSWORD)
                .clientId(clientId)
                .clientSecret(clientSecret)
                .username(adminUsername)
                .password(adminPassword)
                .build();

        RealmResource realmResource = keycloak.realm(realm);
        UsersResource usersResource = realmResource.users();

        List<UserRepresentation> users = usersResource.search(user.getEmail());
        usersResource.delete(users.get(0).getId());
    }

    @Transactional(readOnly = true)
    public List<User> showAllUsers() {
        return userRepository.findAll();
    }

    public User showByEmail(String email) throws UserNotFoundException {
        if(!userRepository.existsByEmail(email))
            throw new UserNotFoundException();
        return userRepository.findUserByEmail(email);
    }
}
