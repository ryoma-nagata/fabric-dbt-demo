with source as (
    select * from {{ source('bronze', 'customers') }}
)

select
    cast(customer_id as int) as customer_id,
    trim(customer_name) as customer_name,
    lower(trim(email)) as email,
    upper(trim(country)) as country_code,
    cast(signup_date as date) as signup_date
from source
