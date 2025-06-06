SET session_replication_role = 'replica';
--
-- PostgreSQL database dump
--

-- Dumped from database version 15.8 (Debian 15.8-1.pgdg120+1)
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
-- Data for Name: deep_fake_mode_lookup; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.deep_fake_mode_lookup (id, enum_name) VALUES (2, 'DeepFake');
INSERT INTO public.deep_fake_mode_lookup (id, enum_name) VALUES (1, 'QuickFake');


--
-- Name: deep_fake_mode_lookup_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.deep_fake_mode_lookup_id_seq', 1, false);


--
-- PostgreSQL database dump complete
--


SET session_replication_role = 'origin';