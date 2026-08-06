select
    o.order_id,
    o.customer_id,
    c.customer_name,
    c.country_code,
    o.order_date,
    o.order_status,
    o.amount,
    case when o.order_status = 'completed' then o.amount else 0 end as recognized_revenue
from {{ ref('stg_orders') }} as o
inner join {{ ref('dim_customers') }} as c
    on o.customer_id = c.customer_id
