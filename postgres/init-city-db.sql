-- ============================================
-- CITYMATE - CITY DB Initialization Script
-- ============================================
-- Schema identique à city-api/src/main/resources/schema.sql
-- + données initiales de city-api/src/main/resources/data.sql
-- ============================================

-- Extension PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

-- ===========================================
-- Table : poi_categories
-- ===========================================
CREATE TABLE IF NOT EXISTS poi_categories (
    id           SERIAL PRIMARY KEY,
    name         VARCHAR(100) NOT NULL UNIQUE,
    description  VARCHAR(255),
    google_types TEXT
);

-- ===========================================
-- Table : event_categories
-- ===========================================
CREATE TABLE IF NOT EXISTS event_categories (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255)
);

-- ===========================================
-- Table : events
-- ===========================================
CREATE TABLE IF NOT EXISTS events (
    id                   SERIAL PRIMARY KEY,
    title                VARCHAR(255) NOT NULL,
    description          TEXT,
    category_id          INTEGER REFERENCES event_categories(id),
    start_date           TIMESTAMP NOT NULL,
    end_date             TIMESTAMP,
    location_name        VARCHAR(255) NOT NULL,
    address              VARCHAR(500) NOT NULL,
    is_free              BOOLEAN DEFAULT true,
    price                DOUBLE PRECISION DEFAULT 0,
    max_participants     INTEGER,
    current_participants INTEGER DEFAULT 0,
    organizer            VARCHAR(255),
    image_url            VARCHAR(500),
    created_by           INTEGER,
    status               VARCHAR(20) NOT NULL DEFAULT 'VALIDATED',
    is_active            BOOLEAN DEFAULT true,
    created_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- Table : event_registrations
-- ===========================================
CREATE TABLE IF NOT EXISTS event_registrations (
    id            SERIAL PRIMARY KEY,
    event_id      INTEGER NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    user_id       INTEGER NOT NULL,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(event_id, user_id)
);

-- ===========================================
-- Table : deal_categories
-- ===========================================
CREATE TABLE IF NOT EXISTS deal_categories (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255)
);

-- ===========================================
-- Table : deals
-- ===========================================
CREATE TABLE IF NOT EXISTS deals (
    id              SERIAL PRIMARY KEY,
    title           VARCHAR(255) NOT NULL,
    description     TEXT,
    category        VARCHAR(100) NOT NULL,
    discount_value  VARCHAR(100) NOT NULL,
    promo_code      VARCHAR(100),
    start_date      DATE NOT NULL,
    end_date        DATE NOT NULL,
    location_name   VARCHAR(255) NOT NULL,
    address         VARCHAR(500) NOT NULL,
    conditions      TEXT,
    website         VARCHAR(500),
    image_url       VARCHAR(500),
    created_by      INTEGER,
    is_active       BOOLEAN DEFAULT true,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- Table : deal_saves
-- ===========================================
CREATE TABLE IF NOT EXISTS deal_saves (
    id        SERIAL PRIMARY KEY,
    deal_id   INTEGER NOT NULL REFERENCES deals(id) ON DELETE CASCADE,
    user_id   INTEGER NOT NULL,
    saved_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(deal_id, user_id)
);

-- ============================================
-- DONNÉES INITIALES
-- ============================================

-- Catégories POI
INSERT INTO poi_categories (name, description, google_types) VALUES
('Restaurant',   'Restaurants et lieux de restauration',                    'restaurant,food'),
('Café',         'Cafés et salons de thé',                                  'cafe'),
('Supermarché',  'Supermarchés et alimentation',                            'supermarket,grocery_or_supermarket'),
('Boulangerie',  'Boulangeries et pâtisseries',                             'bakery'),
('Laverie',      'Laveries automatiques',                                   'laundry'),
('Université',   'Universités et écoles',                                   'university,school'),
('Bibliothèque', 'Bibliothèques et médiathèques',                           'library'),
('Banque',       'Banques et distributeurs',                                'bank,atm'),
('Poste',        'Bureaux de poste',                                        'post_office'),
('Mairie',       'Mairies et administrations',                              'local_government_office,city_hall'),
('Assurance',    'Assurances et mutuelles (CPAM, mutuelle)',                'insurance_agency'),
('Santé',        'Hôpitaux et cliniques',                                   'hospital,doctor'),
('Pharmacie',    'Pharmacies',                                              'pharmacy'),
('Dentiste',     'Cabinets dentaires',                                      'dentist'),
('Transport',    'Gares et stations de transport',                          'transit_station,bus_station,train_station'),
('Bar',          'Bars et vie nocturne',                                    'bar,night_club'),
('Shopping',     'Magasins et centres commerciaux',                         'shopping_mall,store'),
('Musée',        'Musées et galeries',                                      'museum,art_gallery'),
('Parc',         'Parcs et espaces verts',                                  'park'),
('Sport',        'Installations sportives',                                 'gym,stadium'),
('Cinéma',       'Cinémas et spectacles',                                   'movie_theater'),
('Hébergement',  'Hôtels et logements temporaires',                        'lodging')
ON CONFLICT (name) DO NOTHING;

-- Catégories événements
INSERT INTO event_categories (name, description) VALUES
('Culture',        'Sorties culturelles, musées, expos'),
('Sport',          'Activités sportives et plein air'),
('Social',         'Rencontres, afterworks, soirées'),
('Étudiant',       'Événements vie étudiante'),
('Professionnel',  'Networking, conférences, ateliers')
ON CONFLICT (name) DO NOTHING;

-- Événements de test (Brest)
INSERT INTO events (title, description, category_id, start_date, end_date, location_name, address, is_free, price, max_participants, current_participants, organizer, created_by, is_active, status) VALUES
('Soirée d''intégration étudiante',   'Grande soirée de bienvenue pour les nouveaux étudiants brestois. Musique, jeux et buffet.',         4, '2026-04-01 19:00:00', '2026-04-01 23:59:00', 'Le Vauban',                      '17 Avenue Georges Clemenceau, 29200 Brest',   true,  0,    100,  12, 'BDE UBO',                    1, true, 'VALIDATED'),
('Afterwork développeurs Brest',       'Rencontre mensuelle des développeurs brestois. Lightning talks et networking.',                       5, '2026-04-10 18:30:00', '2026-04-10 21:00:00', 'La Cantine Numérique',           '12 Rue du Château, 29200 Brest',              true,  0,    40,   5,  'Brest.js',                   1, true, 'VALIDATED'),
('Tournoi de football 5v5',            'Tournoi amical ouvert à tous. Inscriptions par équipe de 5.',                                         2, '2026-04-15 14:00:00', '2026-04-15 18:00:00', 'Stade de Pen Ar Chleuz',         'Boulevard de Plymouth, 29200 Brest',          false, 5.00, 50,   30, 'AS UBO Sport',               1, true, 'VALIDATED'),
('Visite guidée du musée de la Marine','Découverte du patrimoine maritime brestois avec un guide passionné.',                                 1, '2026-04-20 10:00:00', '2026-04-20 12:00:00', 'Musée National de la Marine',    'Rue du Château, 29200 Brest',                 false, 8.50, 25,   20, 'Office du Tourisme Brest',   1, true, 'VALIDATED'),
('Cours de yoga en plein air',         'Session de yoga accessible à tous niveaux au Jardin des Explorateurs.',                              2, '2026-04-22 09:00:00', '2026-04-22 10:30:00', 'Jardin des Explorateurs',        'Rue de l''Amiral Nicol, 29200 Brest',         true,  0,    NULL, 0,  'Zen Brest',                  1, true, 'VALIDATED'),
('Atelier CV et entretien',            'Atelier pratique pour préparer son CV et simuler des entretiens.',                                    5, '2026-03-01 14:00:00', '2026-03-01 17:00:00', 'Faculté des Lettres UBO',        '20 Rue Duquesne, 29200 Brest',                true,  0,    30,   30, 'Career Center UBO',          1, true, 'VALIDATED')
ON CONFLICT DO NOTHING;

-- Catégories deals
INSERT INTO deal_categories (name, description) VALUES
('Alimentation', 'Restaurants, fast-food, courses'),
('Transport',    'Bus, train, covoiturage, vélo'),
('Loisirs',      'Cinéma, sport, sorties'),
('Shopping',     'Vêtements, high-tech, librairie'),
('Santé',        'Pharmacie, mutuelle, optique')
ON CONFLICT (name) DO NOTHING;

-- Deals (Brest — bons plans étudiants)
INSERT INTO deals (title, description, category, discount_value, promo_code, start_date, end_date, location_name, address, conditions, website, created_by, is_active) VALUES
('Menu étudiant à 8.90€',          'Menu complet entrée + plat + dessert à prix réduit du lundi au vendredi midi.',          'Alimentation', '8.90€',      NULL,       '2026-01-01', '2026-12-31', 'Crêperie Blé Noir',                          '3 Rue de Siam, 29200 Brest',                     'Sur présentation de la carte étudiante.',                     NULL,                               1, true),
('Abonnement Bibus -50% étudiant', 'Tarif réduit sur l''abonnement mensuel du réseau de bus et tramway brestois.',           'Transport',    '-50%',        NULL,       '2026-01-01', '2026-12-31', 'Agence Bibus — Porte de Guipavas',           '33 Avenue Georges Clemenceau, 29200 Brest',      'Moins de 26 ans avec justificatif de scolarité.',             'https://www.bibus.fr',             1, true),
('Séance ciné à 5€',               NULL,                                                                                      'Loisirs',      '5€',          NULL,       '2026-01-01', '2026-12-31', 'Cinéma Les Studios',                         '136 Rue Jean Jaurès, 29200 Brest',               'Tarif étudiant sur présentation de la carte.',                'https://www.cgrcinemas.fr',        1, true),
('-10% papeterie et fournitures',  'Remise sur tout le rayon papeterie et fournitures scolaires.',                           'Shopping',     '-10%',        'DIALOG10', '2026-03-01', '2026-06-30', 'Librairie Dialogues',                        '17-21 Rue Traverse, 29200 Brest',                'Non cumulable avec d''autres offres.',                        'https://www.librairiedialogues.fr',1, true),
('Consultation gratuite SUMPPS',   'Consultation médicale gratuite au Service Universitaire de Médecine Préventive.',        'Santé',        'Gratuit',     NULL,       '2026-01-01', '2026-12-31', 'SUMPPS — Université de Bretagne Occidentale','20 Avenue Le Gorgeu, 29238 Brest',               'Réservé aux étudiants de l''UBO. Sur rendez-vous.',           NULL,                               1, true),
('1 galette achetée = 1 offerte',  'Le mardi soir, une galette complète offerte pour une galette achetée.',                  'Alimentation', '1+1 offert',  NULL,       '2026-03-01', '2026-07-31', 'Crêperie La Krampouzerie',                   '8 Rue de l''Eau Blanche, 29200 Brest',           'Le mardi soir uniquement, sur place.',                        NULL,                               1, true),
('Sport illimité 19.99€/mois',     NULL,                                                                                      'Loisirs',      '19.99€/mois', NULL,       '2026-01-01', '2026-12-31', 'Basic-Fit Brest Siam',                       '2 Rue de Siam, 29200 Brest',                     'Engagement 12 mois. Carte étudiante requise.',                'https://www.basic-fit.com',        1, true),
('Happy Hour pinte à 3.50€',       'Pinte de bière à prix réduit tous les soirs de 18h à 20h.',                              'Alimentation', '3.50€',       NULL,       '2026-01-01', '2026-12-31', 'Le Vauban',                                  '17 Avenue Georges Clemenceau, 29200 Brest',      NULL,                                                           NULL,                               1, true),
('Location vélo électrique 1€/jour','Tarif étudiant pour les vélos en libre-service du réseau Bibus.',                       'Transport',    '1€/jour',     NULL,       '2026-04-01', '2026-10-31', 'Stations Bibus Vélo',                        'Place de la Liberté, 29200 Brest',               'Abonnement étudiant Bibus obligatoire.',                      'https://www.bibus.fr',             1, true),
('Escape Game -30% en groupe',     'Réduction pour les groupes de 4 personnes ou plus.',                                     'Loisirs',      '-30%',        'ESCAPE30', '2026-03-01', '2026-08-31', 'Get Out! Brest',                             '25 Rue Algésiras, 29200 Brest',                  'Groupe de 4 minimum. Réservation en ligne.',                  'https://www.getout.fr/brest',      1, true),
('Lunettes à 1€ avec mutuelle',    NULL,                                                                                      'Santé',        '1€',          NULL,       '2026-01-01', '2026-12-31', 'Optic 2000 — Rue de Siam',                   '45 Rue de Siam, 29200 Brest',                    'Avec mutuelle étudiante. Montures sélection.',                'https://www.optic2000.com',        1, true),
('-15% coupe homme/femme',         NULL,                                                                                      'Shopping',     '-15%',        NULL,       '2026-03-01', '2026-09-30', 'Tchip Coiffure Brest',                       '50 Rue Jean Jaurès, 29200 Brest',                'Du lundi au mercredi, sans rendez-vous.',                     NULL,                               1, true)
ON CONFLICT DO NOTHING;
