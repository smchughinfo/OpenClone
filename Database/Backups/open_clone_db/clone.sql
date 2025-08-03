SET session_replication_role = 'replica';
--
-- PostgreSQL database dump
--

-- Dumped from database version 15.13 (Debian 15.13-1.pgdg120+1)
-- Dumped by pg_dump version 16.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: clone; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.clone (id, application_user_id, voice_id, create_date, system_message, allow_logging, first_name, last_name, nick_name, age, biography, city, state, occupation, make_public, deep_fake_mode_lookup_id) VALUES (1, '8634b089-149e-48a8-b8c2-fc2d4a40df2a', '58uI5et7Ak5Yg34GGgLh', '2023-06-07 04:19:06.757538+00', NULL, true, 'Cat', 'Girl', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1);
INSERT INTO public.clone (id, application_user_id, voice_id, create_date, system_message, allow_logging, first_name, last_name, nick_name, age, biography, city, state, occupation, make_public, deep_fake_mode_lookup_id) VALUES (2, '8634b089-149e-48a8-b8c2-fc2d4a40df2a', 'cafxHMneOsIz793A0ch0', '2023-06-07 04:19:18.102585+00', NULL, true, 'Sean', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1);


--
-- Name: clone_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.clone_id_seq', 4, true);


--
-- PostgreSQL database dump complete
--


SET session_replication_role = 'origin';