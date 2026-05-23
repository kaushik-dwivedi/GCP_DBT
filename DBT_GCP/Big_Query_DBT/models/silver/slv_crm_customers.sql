WITH source AS (
    SELECT * FROM {{ ref('brz_crm_customers') }}
),

renamed AS (
    SELECT
        customer_id,
        customer_unique_id,
        CAST(customer_zip_code_prefix AS INT64)  AS customer_zip_code_prefix,
        INITCAP(customer_city)                   AS customer_city,
        UPPER(customer_state)                    AS customer_state
    FROM source
),

deduplicated AS (
    SELECT *
    FROM renamed
    QUALIFY ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY customer_id) = 1
),

filtered AS (
    SELECT *
    FROM deduplicated
    WHERE customer_id IS NOT NULL
      AND customer_unique_id IS NOT NULL
      AND customer_zip_code_prefix IS NOT NULL
)

SELECT * FROM filtered