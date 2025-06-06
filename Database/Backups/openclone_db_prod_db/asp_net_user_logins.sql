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
-- Data for Name: asp_net_user_logins; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.asp_net_user_logins (login_provider, provider_key, provider_display_name, user_id) VALUES ('Google', '109201436256225631298', 'Google', '8634b089-149e-48a8-b8c2-fc2d4a40df2a');
INSERT INTO public.asp_net_user_logins (login_provider, provider_key, provider_display_name, user_id) VALUES ('Google', '112313845136674666072', 'Google', '9e965efb-1f9b-4ef5-93bc-8778a7c10ff6');


--
-- PostgreSQL database dump complete
--


SET session_replication_role = 'origin';