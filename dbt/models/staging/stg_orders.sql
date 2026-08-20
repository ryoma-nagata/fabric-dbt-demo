with source as (
    select * from {{ ref('orders') }}
)

select
    cast(order_id as int) as order_id,
    cast(customer_id as int) as customer_id,
    cast(order_date as date) as order_date,
    lower(trim(status)) as order_status,
    cast(amount as decimal(12, 2)) as amount
from source
