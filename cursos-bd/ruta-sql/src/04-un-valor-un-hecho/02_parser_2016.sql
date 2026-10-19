-- postgres
-- dbo.fn_ExtraerDNI y dbo.fn_ExtraerFecha, de tsql/fn_ExtraerDNI.sql (Matías, 2016), portadas línea a
-- línea. Se portan con sus defectos: es la copia que los reportes usaron diez años.

-- TRY_CONVERT(date, @t, 3): dd/mm/aa, con el corte de dos dígitos de SQL Server (de 00 a 49 es 20xx).
CREATE OR REPLACE FUNCTION staging.try_date_style3(t text) RETURNS date
LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE
    m text[] := regexp_match(t, '^([0-9]{1,2})/([0-9]{1,2})/([0-9]{2})$');
    yy int;
BEGIN
    IF m IS NULL THEN
        RETURN NULL;
    END IF;
    yy := m[3]::int;
    RETURN make_date(CASE WHEN yy < 50 THEN 2000 + yy ELSE 1900 + yy END, m[2]::int, m[1]::int);
EXCEPTION WHEN datetime_field_overflow OR invalid_datetime_format THEN
    RETURN NULL;                                 -- TRY_CONVERT devuelve NULL, no un error
END $$;

-- TRY_CONVERT(date, @t, 103): dd/mm/aaaa.
CREATE OR REPLACE FUNCTION staging.try_date_style103(t text) RETURNS date
LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE
    m text[] := regexp_match(t, '^([0-9]{1,2})/([0-9]{1,2})/([0-9]{4})$');
BEGIN
    IF m IS NULL THEN
        RETURN NULL;
    END IF;
    RETURN make_date(m[3]::int, m[2]::int, m[1]::int);
EXCEPTION WHEN datetime_field_overflow OR invalid_datetime_format THEN
    RETURN NULL;
END $$;

CREATE OR REPLACE FUNCTION staging.extract_dni_2016(raw text) RETURNS text
LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE
    rest       text := btrim(coalesce(raw, ''));
    t          text;
    u          text;
    next_token text;
    after_next text;
    dni        text := '';
    is_first   boolean := true;
    p          int;
BEGIN
    WHILE length(rest) > 0 LOOP
        p := position(' ' IN rest);
        IF p = 0 THEN
            t := rest; rest := '';
        ELSE
            t := left(rest, p - 1); rest := ltrim(substr(rest, p + 1));
        END IF;
        u := upper(t);

        -- el token que sigue, sin consumirlo
        p := position(' ' IN rest);
        next_token := CASE WHEN p = 0 THEN rest ELSE left(rest, p - 1) END;

        IF u IN ('DNI', 'LE', 'LC') AND dni = '' AND length(rest) > 0 THEN
            dni := replace(next_token, '.', '');
            rest := ltrim(substr(rest, length(next_token) + 2));
        ELSIF u IN ('P', 'PASAP') AND dni = '' AND position(' ' IN rest) > 0 THEN
            -- pasaporte: el país y después el número
            rest := ltrim(substr(rest, length(next_token) + 2));
            p := position(' ' IN rest);
            after_next := CASE WHEN p = 0 THEN rest ELSE left(rest, p - 1) END;
            dni := after_next;
            rest := ltrim(substr(rest, length(after_next) + 2));
        ELSIF u = 'RN' AND is_first THEN
            NULL;                                -- recién nacido: el DNI que venga es el de la madre
        ELSIF position('/' IN t) > 0 AND staging.try_date_style3(t) IS NOT NULL THEN
            NULL;                                -- una fecha: el reporte usa extract_birth_date_2016
        ELSIF dni = '' AND t !~ '[^0-9.]' AND length(replace(t, '.', '')) >= 7 THEN
            dni := replace(t, '.', '');
        END IF;
        is_first := false;
    END LOOP;
    RETURN dni;
END $$;

CREATE OR REPLACE FUNCTION staging.extract_birth_date_2016(raw text) RETURNS date
LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE
    rest text := btrim(coalesce(raw, ''));
    t    text;
    p    int;
BEGIN
    WHILE length(rest) > 0 LOOP
        p := position(' ' IN rest);
        IF p = 0 THEN
            t := rest; rest := '';
        ELSE
            t := left(rest, p - 1); rest := ltrim(substr(rest, p + 1));
        END IF;
        IF position('/' IN t) > 0 THEN
            -- estilo 103 si trae el año con cuatro cifras; si no, el 3 (dd/mm/aa)
            IF t ~ '/[0-9]{4}$' THEN
                RETURN staging.try_date_style103(t);
            END IF;
            RETURN staging.try_date_style3(t);
        END IF;
    END LOOP;
    RETURN NULL;
END $$;
