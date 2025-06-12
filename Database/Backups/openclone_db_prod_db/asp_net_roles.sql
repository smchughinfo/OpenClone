SET session_replication_role = 'replica';
--
-- PostgreSQL database dump
--

-- Dumped from database version 16.1
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
-- Data for Name: asp_net_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.asp_net_roles (id, name, normalized_name, concurrency_stamp) VALUES ('d759eb91-d1d4-4672-8797-62dca8397cf4', 'Overlord', 'OVERLORD', NULL);
INSERT INTO public.asp_net_roles (id, name, normalized_name, concurrency_stamp) VALUES ('151269dd-d7a7-478a-8ca3-ef5ed64a1af6', 'SuperUser', 'SUPERUSER', NULL);
INSERT INTO public.asp_net_roles (id, name, normalized_name, concurrency_stamp) VALUES ('d94487aa-39ac-4b00-a3a4-2e5739698ea2', 'User', 'USER', NULL);


--
-- PostgreSQL database dump complete
--


SET session_replication_role = 'origin';