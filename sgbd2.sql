-- L'aéroport international de Casablanca est un des aéroports les plus importants actuellement. Il souhaite informatiser la gestion des vols. L'étude de l'existant a permis d'élaborer le schéma relationnel suivant :
-- Pilote(N°pilote ,nom-pilote, Prénom-pilote,DateNaissance localisation)
-- Vol (N°vol,N°pilote,N°avion,datdépart,datarrivée,villedépart, villearrivée,durée,tarif) 
-- Passagers (N°passager, Nom-passager, adresse, téléphone,type)
-- Avion (N°avion,marque, capacité,etat) 
-- Réservation (N°passager, N°vol,montApayer)
-- Remarque:
-- Le champ "type" prend la valeur "adulte" ou "enfant"
-- Le champ "etat" de la table avion prend la valeur "en vol" ou "disponible"
-- Questions:
-- Procédures Stockées
-- Triggers
-- 1. Créer une PS qui permet l'ajout d'un pilote après vérification de son existence.
-- 2. Créer une PS qui permet de donner le nombre de vol d'un pilote donné. 
-- 3. Créer une PS qui permet de donner le nombre de passager d'un vol donné.
-- 4. Créer une PS qui permet l'ajout d'une réservation et qui met à jour le montant de la réservation lors de l'insertion :
-- Si le passager est adulte le montant est égal au tarif défini dans la table vol sinon le montant est la moitié du tarif.
-- 5. Créer une PS qui permet de supprimer les pilotes dont l'âge est supérieur à 50 ans et de les archiver dans une autre table << AncienPilote » qui a la même structure que la table << Pilote >>.
-- 6. Créer une PS qui permet l'ajout d'un vol, le pilote ne doit pas avoir plus de 3 vols dans un mois donné et l'avion doit être disponible.
-- 7. Créer une PS qui permet l'ajout d'un passager, Le N°passager est affecté automatiquement après avoir vérifié que le numéro affecté n'existe pas déjà dans la table passager.
-- 8. Créer un trigger qui permet d'ajouter une réservation d'un vol que si le nombre de passager est inférieur à 200 sinon afficher un message "places complets pour ce vol"
-- 9. Créer un trigger qui interdit l'ajout d'un vol si la date d'arrivée du vol est inférieure à la date de départ.
-- 10. Créer un trigger qui interdit l'ajout d'un vol si l'avion concerné n'est pas disponible
------------------------------------------------------------------------------------------------
-- 1. Créer une PS qui permet l'ajout d'un pilote après vérification de son existence.
DELIMITER //
CREATE [OR REPLACE] PROCEDURE [IF NOT EXISTS] `AjoutPilote`(IN p_NumPilote INT, IN p_NomPilote VARCHAR(50), IN p_PrenomPilote VARCHAR(50), IN p_DateNaissance DATE, IN p_Localisation VARCHAR(50))
[OPTIONS (strict_mode = TRUE|FALSE)]
IF NOT EXISTS (SELECT 1 FROM Pilote WHERE N°pilote = p_NumPilote) THEN
        INSERT INTO Pilote (N°pilote, nom-pilote, Prénom-pilote, DateNaissance, localisation)
        VALUES (p_NumPilote, p_NomPilote, p_PrenomPilote, p_DateNaissance, p_Localisation);
    END IF;
END//
DELIMITER ;
-- 2. Créer une PS qui permet de donner le nombre de vol d'un pilote donné. 
DELIMITER //
CREATE [OR REPLACE] PROCEDURE [IF NOT EXISTS] `NombreVolsPilote`(IN p_NumPilote INT, OUT p_NombreVols INT)
[OPTIONS (strict_mode = TRUE|FALSE)]
BEGIN
    SELECT COUNT(*) INTO p_NombreVols FROM Vol WHERE N°pilote = p_NumPilote;
END//
DELIMITER ;
-- 3. Créer une PS qui permet de donner le nombre de passager d'un vol donné.
DELIMITER //
CREATE [OR REPLACE] PROCEDURE [IF NOT EXISTS] `NombrePassagersVol`(IN p_NumVol INT, OUT p_NombrePassagers INT)
[OPTIONS (strict_mode = TRUE|FALSE)]
BEGIN
    SELECT COUNT(*) INTO p_NombrePassagers FROM Reservation WHERE N°vol = p_NumVol;
END//
DELIMITER ;
-- 4. Créer une PS qui permet l'ajout d'une réservation et qui met à jour le montant de la réservation lors de l'insertion : Si le passager est adulte le montant est égal au tarif défini dans la table vol sinon le montant est la moitié du tarif.
DELIMITER //
CREATE [OR REPLACE] PROCEDURE [IF NOT EXISTS] `AjoutReservation`(IN p_NumPassager INT, IN p_NumVol INT)
[OPTIONS (strict_mode = TRUE|FALSE)]
BEGIN
     DECLARE v_Tarif DOUBLE;
    DECLARE v_Type VARCHAR(10);

    SELECT type, tarif INTO v_Type, v_Tarif FROM Passagers JOIN Vol ON Passagers.N°passager = p_NumPassager AND Vol.N°vol = p_NumVol;

    IF v_Type = 'adulte' THEN
        INSERT INTO Reservation (N°passager, N°vol, montApayer) VALUES (p_NumPassager, p_NumVol, v_Tarif);
    ELSE
        INSERT INTO Reservation (N°passager, N°vol, montApayer) VALUES (p_NumPassager, p_NumVol, v_Tarif * 0.5);
    END IF;
END//
DELIMITER ;
-- 5. Créer une PS qui permet de supprimer les pilotes dont l'âge est supérieur à 50 ans et de les archiver dans une autre table << AncienPilote » qui a la même structure que la table << Pilote >>.
DELIMITER //
CREATE [OR REPLACE] PROCEDURE [IF NOT EXISTS] `SupprimerArchiverPilotes`()
[OPTIONS (strict_mode = TRUE|FALSE)]
BEGIN
  INSERT INTO AncienPilote
  SELECT * FROM Pilote
  WHERE DATE_ADD(DateNaissance, INTERVAL 50 YEAR) < CURDATE();

  DELETE FROM Pilote
  WHERE DATE_ADD(DateNaissance, INTERVAL 50 YEAR) < CURDATE();
END//
DELIMITER ;
-- 6. Créer une PS qui permet l'ajout d'un vol, le pilote ne doit pas avoir plus de 3 vols dans un mois donné et l'avion doit être disponible.
DELIMITER //
CREATE [OR REPLACE] PROCEDURE [IF NOT EXISTS] `ajout_vol`( IN N°pilote INT, IN N°avion INT, IN datdepart DATETIME, IN datarrivee DATETIME, IN villedépart VARCHAR(50), IN villearrivee VARCHAR(50), IN duree FLOAT, IN tarif FLOAT)
[OPTIONS (strict_mode = TRUE|FALSE)]
BEGIN
    -- Vérifier que le pilote a moins de 3 vols dans le mois du vol à ajouter
    IF (SELECT COUNT(*) FROM Vol 
        WHERE N°pilote = N°pilote
        AND MONTH(datdépart) = MONTH(datdepart)
        AND YEAR(datdépart) = YEAR(datdepart)
    ) >= 3
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Le pilote a déjà atteint le nombre maximal de vols pour ce mois.';
        RETURN;
    END IF;
    
    -- Vérifier que l'avion est disponible
    IF (SELECT etat FROM Avion WHERE N°avion = N°avion) <> 'disponible'
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'L''avion est déjà utilisé pour un autre vol.';
        RETURN;
    END IF;
    
    -- Ajouter le vol
    INSERT INTO Vol (N°pilote, N°avion, datdépart, datarrivée, villedépart, villearrivée, durée, tarif)
    VALUES (Nopilote, Noavion, datdepart, datarrivee, villedépart, villearrivee, duree, tarif);
    
END//
DELIMITER ;
-- 7. Créer une PS qui permet l'ajout d'un passager, Le N°passager est affecté automatiquement après avoir vérifié que le numéro affecté n'existe pas déjà dans la table passager.
DELIMITER //
CREATE [OR REPLACE] PROCEDURE [IF NOT EXISTS] `AjoutPassager`(IN p_NomPassager VARCHAR(50), IN p_Adresse VARCHAR(100), IN p_Telephone VARCHAR(20), IN p_Type VARCHAR(10))
[OPTIONS (strict_mode = TRUE|FALSE)]
BEGIN
    -- Vérifier si le numéro de passager existe déjà
 DECLARE v_NumPassager INT;
    SELECT MAX(N°passager) + 1 INTO v_NumPassager FROM Passagers;
    -- Ajouter le passager    
    INSERT INTO Passagers (N°passager, Nom-passager, adresse, téléphone, type)
    VALUES (v_NumPassager, p_NomPassager, p_Adresse, p_Telephone, p_Type);

END//
DELIMITER ;
-- 8. Créer un trigger qui permet d'ajouter une réservation d'un vol que si le nombre de passager est inférieur à 200 sinon afficher un message "places complets pour ce vol"
DELIMITER //
CREATE TRIGGER reservation_before_insert
BEFORE INSERT ON Réservation
FOR EACH ROW
BEGIN
    -- Vérifier que le nombre de passagers est inférieur à 200
    DECLARE nb_passagers INT;
    SELECT COUNT(*) INTO nb_passagers FROM Réservation WHERE N°vol = NEW.N°vol;
    IF nb_passagers >= 200 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Places complètes pour ce vol.';
    END IF;

END//
DELIMITER ;
-- 9. Créer un trigger qui interdit l'ajout d'un vol si la date d'arrivée du vol est inférieure à la date de départ.
DELIMITER //
create TRIGGER VerifierDatesVol
BEFORE INSERT ON Vol
FOR EACH ROW 
BEGIN
 -- Vérifier que la date d'arrivée est supérieure ou égale à la date de départ
    IF NEW.datarrivée < NEW.datdépart THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La date d''arrivée doit être supérieure ou égale à la date de départ.';
    END IF;
END //
DELIMITER;
-- 10. Créer un trigger qui interdit l'ajout d'un vol si l'avion concerné n'est pas disponible
DELIMITER //
create TRIGGER VerifierDisponibiliteAvion
BEFORE INSERT ON Vol
FOR EACH ROW 
BEGIN
 -- Vérifier que l'avion est disponible
    IF (SELECT etat FROM Avion WHERE N°avion = NEW.N°avion) <> 'disponible' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'L''avion n''est pas disponible.';
    END IF;
END //
DELIMITER;