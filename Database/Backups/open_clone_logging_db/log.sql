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
-- Data for Name: log; Type: TABLE DATA; Schema: public; Owner: open_clone_logger
--

INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (1, 1, 'Website', true, '2024-07-02 15:43:25.503577-04', 'Website - Run Number Incremented', '', 'INFO', 'SEANSDESKTOP', '192.168.0.100');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (2, 2, 'Website', true, '2024-07-02 19:12:25.959832-04', 'Website - Run Number Incremented', '', 'INFO', 'SEANSDESKTOP', '192.168.0.100');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (3, 3, 'Website', true, '2024-07-02 21:24:27.811297-04', 'Website - Run Number Incremented', '', 'INFO', 'SEANSDESKTOP', '192.168.0.100');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (4, 1, 'SadTalker', true, '2024-07-03 02:26:59.592229-04', 'SadTalker - Run Number Incremented', '', 'INFO', '9e4a57fea2ce', '172.17.0.2');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (5, 1, 'SadTalker', true, '2024-07-03 02:27:06.228426-04', 'Starting SadTalker', '', 'INFO', '9e4a57fea2ce', '172.17.0.2');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (6, 1, 'SadTalker', true, '2024-07-03 02:27:06.228563-04', '⚠️⚠️⚠️ ATTENTION! IF IT TRIES USING AN AUDIO FILE PATH THAT YOU ARE NOT SUPPLYING AS A PARAMETER TO THE HTTP POST /generate-deepfake endpoint IT MAY BE ''STUCK''. THAT IS THE PREVIOUS RUN NEVER FINISHED AND SUBSEQUENT RUNS WILL TRY TO USE THE SAME CACHE AND THEN FAIL. DELETE SADTALKER_CACHE FOR THIS CLONE AND YOU SHOULD SEE IT START USING THE RIGHT AUDIO FILE PATH ⚠️⚠️⚠️', '', 'INFO', '9e4a57fea2ce', '172.17.0.2');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (7, 1, 'U-2-Net', true, '2024-07-03 02:27:10.09359-04', 'U-2-Net - Run Number Incremented', '', 'INFO', 'd3de6093944f', '172.17.0.3');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (8, 1, 'U-2-Net', true, '2024-07-03 02:27:11.787579-04', 'Starting U-2-Net', '', 'INFO', 'd3de6093944f', '172.17.0.3');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (9, 4, 'Website', true, '2024-07-03 02:41:17.837772-04', 'Website - Run Number Incremented', '', 'INFO', 'SEANSDESKTOP', '192.168.0.100');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (10, 5, 'Website', true, '2024-07-03 02:48:27.623736-04', 'Website - Run Number Incremented', '', 'INFO', 'SEANSDESKTOP', '192.168.0.100');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (11, 6, 'Website', true, '2024-07-03 02:52:54.844529-04', 'Website - Run Number Incremented', '', 'INFO', 'SEANSDESKTOP', '192.168.0.100');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (12, 7, 'Website', true, '2024-07-03 02:57:02.438387-04', 'Website - Run Number Incremented', '', 'INFO', 'SEANSDESKTOP', '192.168.0.100');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (13, 8, 'Website', true, '2024-07-03 09:53:38.615829-04', 'Website - Run Number Incremented', '', 'INFO', 'SEANSDESKTOP', '192.168.0.100');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (14, 1, 'SadTalker', true, '2024-07-03 22:42:21.954333-04', 'SadTalker - Run Number Incremented', '', 'INFO', '067a0555fae7', '172.17.0.2');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (15, 1, 'U-2-Net', true, '2024-07-03 22:42:21.963687-04', 'U-2-Net - Run Number Incremented', '', 'INFO', '4c28426c6461', '172.17.0.3');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (16, 1, 'U-2-Net', true, '2024-07-03 22:42:25.351438-04', 'Starting U-2-Net', '', 'INFO', '4c28426c6461', '172.17.0.3');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (17, 1, 'SadTalker', true, '2024-07-03 22:42:30.920861-04', 'Starting SadTalker', '', 'INFO', '067a0555fae7', '172.17.0.2');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (18, 1, 'SadTalker', true, '2024-07-03 22:42:30.921014-04', '⚠️⚠️⚠️ ATTENTION! IF IT TRIES USING AN AUDIO FILE PATH THAT YOU ARE NOT SUPPLYING AS A PARAMETER TO THE HTTP POST /generate-deepfake endpoint IT MAY BE ''STUCK''. THAT IS THE PREVIOUS RUN NEVER FINISHED AND SUBSEQUENT RUNS WILL TRY TO USE THE SAME CACHE AND THEN FAIL. DELETE SADTALKER_CACHE FOR THIS CLONE AND YOU SHOULD SEE IT START USING THE RIGHT AUDIO FILE PATH ⚠️⚠️⚠️', '', 'INFO', '067a0555fae7', '172.17.0.2');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (19, 9, 'Website', true, '2024-09-08 04:35:19.348652-04', 'Website - Run Number Incremented', '', 'INFO', 'SEANSDESKTOP', '192.168.0.100');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (20, 10, 'Website', true, '2024-09-08 04:37:02.350485-04', 'Website - Run Number Incremented', '', 'INFO', 'SEANSDESKTOP', '192.168.0.100');
INSERT INTO public.log (log_id, run_number, application_name, open_clone_log, "timestamp", message, tags, level, machine_name, ip_address) VALUES (21, 11, 'Website', true, '2024-09-08 04:39:47.360597-04', 'Website - Run Number Incremented', '', 'INFO', 'SEANSDESKTOP', '192.168.0.100');


--
-- Name: log_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: open_clone_logger
--

SELECT pg_catalog.setval('public.log_log_id_seq', 21, true);


--
-- PostgreSQL database dump complete
--


SET session_replication_role = 'origin';