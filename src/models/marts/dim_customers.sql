select
    customer_id,
    customer_name,
    email,
    country_code,
    signup_date
from {{ ref('stg_customers') }}
