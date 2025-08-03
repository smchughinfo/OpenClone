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

INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (1, 1, 'Website', true, '2024-07-02 19:43:25.503577+00', 'Website - Run Number Incremented', '', 'INFO', 'SEANSDESKTOP', '192.168.0.100');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (2, 2, 'Website', true, '2024-07-02 23:12:25.959832+00', 'Website - Run Number Incremented', '', 'INFO', 'SEANSDESKTOP', '192.168.0.100');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (3, 3, 'Website', true, '2024-07-03 01:24:27.811297+00', 'Website - Run Number Incremented', '', 'INFO', 'SEANSDESKTOP', '192.168.0.100');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (4, 1, 'SadTalker', true, '2024-07-03 06:26:59.592229+00', 'SadTalker - Run Number Incremented', '', 'INFO', '9e4a57fea2ce', '172.17.0.2');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (5, 1, 'SadTalker', true, '2024-07-03 06:27:06.228426+00', 'Starting SadTalker', '', 'INFO', '9e4a57fea2ce', '172.17.0.2');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (6, 1, 'SadTalker', true, '2024-07-03 06:27:06.228563+00', '⚠️⚠️⚠️ ATTENTION! IF IT TRIES USING AN AUDIO FILE PATH THAT YOU ARE NOT SUPPLYING AS A PARAMETER TO THE HTTP POST /generate-deepfake endpoint IT MAY BE ''STUCK''. THAT IS THE PREVIOUS RUN NEVER FINISHED AND SUBSEQUENT RUNS WILL TRY TO USE THE SAME CACHE AND THEN FAIL. DELETE SADTALKER_CACHE FOR THIS CLONE AND YOU SHOULD SEE IT START USING THE RIGHT AUDIO FILE PATH ⚠️⚠️⚠️', '', 'INFO', '9e4a57fea2ce', '172.17.0.2');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (7, 1, 'U-2-Net', true, '2024-07-03 06:27:10.09359+00', 'U-2-Net - Run Number Incremented', '', 'INFO', 'd3de6093944f', '172.17.0.3');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (8, 1, 'U-2-Net', true, '2024-07-03 06:27:11.787579+00', 'Starting U-2-Net', '', 'INFO', 'd3de6093944f', '172.17.0.3');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (9, 4, 'Website', true, '2024-07-03 06:41:17.837772+00', 'Website - Run Number Incremented', '', 'INFO', 'SEANSDESKTOP', '192.168.0.100');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (10, 5, 'Website', true, '2024-07-03 06:48:27.623736+00', 'Website - Run Number Incremented', '', 'INFO', 'SEANSDESKTOP', '192.168.0.100');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (11, 6, 'Website', true, '2024-07-03 06:52:54.844529+00', 'Website - Run Number Incremented', '', 'INFO', 'SEANSDESKTOP', '192.168.0.100');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (12, 7, 'Website', true, '2024-07-03 06:57:02.438387+00', 'Website - Run Number Incremented', '', 'INFO', 'SEANSDESKTOP', '192.168.0.100');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (13, 8, 'Website', true, '2024-07-03 13:53:38.615829+00', 'Website - Run Number Incremented', '', 'INFO', 'SEANSDESKTOP', '192.168.0.100');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (14, 1, 'SadTalker', true, '2024-07-04 02:42:21.954333+00', 'SadTalker - Run Number Incremented', '', 'INFO', '067a0555fae7', '172.17.0.2');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (15, 1, 'U-2-Net', true, '2024-07-04 02:42:21.963687+00', 'U-2-Net - Run Number Incremented', '', 'INFO', '4c28426c6461', '172.17.0.3');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (16, 1, 'U-2-Net', true, '2024-07-04 02:42:25.351438+00', 'Starting U-2-Net', '', 'INFO', '4c28426c6461', '172.17.0.3');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (17, 1, 'SadTalker', true, '2024-07-04 02:42:30.920861+00', 'Starting SadTalker', '', 'INFO', '067a0555fae7', '172.17.0.2');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (18, 1, 'SadTalker', true, '2024-07-04 02:42:30.921014+00', '⚠️⚠️⚠️ ATTENTION! IF IT TRIES USING AN AUDIO FILE PATH THAT YOU ARE NOT SUPPLYING AS A PARAMETER TO THE HTTP POST /generate-deepfake endpoint IT MAY BE ''STUCK''. THAT IS THE PREVIOUS RUN NEVER FINISHED AND SUBSEQUENT RUNS WILL TRY TO USE THE SAME CACHE AND THEN FAIL. DELETE SADTALKER_CACHE FOR THIS CLONE AND YOU SHOULD SEE IT START USING THE RIGHT AUDIO FILE PATH ⚠️⚠️⚠️', '', 'INFO', '067a0555fae7', '172.17.0.2');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (19, 9, 'Website', true, '2024-09-08 08:35:19.348652+00', 'Website - Run Number Incremented', '', 'INFO', 'SEANSDESKTOP', '192.168.0.100');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (20, 10, 'Website', true, '2024-09-08 08:37:02.350485+00', 'Website - Run Number Incremented', '', 'INFO', 'SEANSDESKTOP', '192.168.0.100');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (21, 11, 'Website', true, '2024-09-08 08:39:47.360597+00', 'Website - Run Number Incremented', '', 'INFO', 'SEANSDESKTOP', '192.168.0.100');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (22, 12, 'Website', true, '2025-08-03 18:45:35.156582+00', 'Website - Run Number Incremented', '', 'INFO', 'SEANSDESKTOP', '172.29.64.1');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (23, 12, 'Website', true, '2025-08-03 18:45:35.96365+00', 'deleting voiceId 58uI5et7Ak5Yg34GGgLh', '', 'INFO', 'SEANSDESKTOP', '172.29.64.1');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (24, 12, 'Website', true, '2025-08-03 18:49:42.967055+00', 'deleting voiceId cafxHMneOsIz793A0ch0', '', 'INFO', 'SEANSDESKTOP', '172.29.64.1');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (25, 12, 'Website', true, '2025-08-03 18:49:44.015884+00', 'adding voice for clone 2', '', 'INFO', 'SEANSDESKTOP', '172.29.64.1');


--
-- Name: log_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.log_log_id_seq', 25, true);


--
-- PostgreSQL database dump complete
--


SET session_replication_role = 'origin';