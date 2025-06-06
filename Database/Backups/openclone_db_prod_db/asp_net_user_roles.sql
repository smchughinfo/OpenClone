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
-- Data for Name: asp_net_user_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.asp_net_user_roles (user_id, role_id) VALUES ('8634b089-149e-48a8-b8c2-fc2d4a40df2a', 'd759eb91-d1d4-4672-8797-62dca8397cf4');


--
-- PostgreSQL database dump complete
--


SET session_replication_role = 'origin';