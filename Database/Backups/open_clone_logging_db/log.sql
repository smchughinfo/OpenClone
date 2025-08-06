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
-- Data for Name: log; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (1, 1, 'Website', true, '2025-08-03 19:43:25.503577+00', 'Website - Run Number Incremented', '', 'INFO', 'SEANSDESKTOP', '192.168.0.100');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (2, 1, 'SadTalker', true, '2025-08-03 06:26:59.592229+00', 'SadTalker - Run Number Incremented', '', 'INFO', '9e4a57fea2ce', '172.17.0.2');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (3, 1, 'U-2-Net', true, '2025-87-03 06:27:10.09359+00', 'U-2-Net - Run Number Incremented', '', 'INFO', 'd3de6093944f', '172.17.0.3');


--
-- Name: log_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.log_log_id_seq', 3, true);


--
-- PostgreSQL database dump complete
--


SET session_replication_role = 'origin';