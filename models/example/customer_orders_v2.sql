WITH paid_orders as (
    select 
        o.order_id,
        o.customer_id,
        o.order_placed_at,
        o.order_status,
        p.total_amount_paid,
        p.payment_finalized_date,
        C.FIRST_NAME    as customer_first_name,
        C.LAST_NAME as customer_last_name
FROM {{ ref('base_orders') }} as o
left join (select ORDERID as order_id, max(CREATED) as payment_finalized_date, sum(AMOUNT) / 100.0 as total_amount_paid
        from {{ ref('stripe_payments') }}
        where STATUS <> 'fail'
        group by 1) p using (order_id)
left join {{ ref('jaffle_shop_customers') }} C on o.customer_id = C.ID ),

customer_orders 
as (select C.ID as customer_id
    , min(o.order_placed_at) as first_order_date
    , max(o.order_placed_at) as most_recent_order_date
    , count(o.order_id) AS number_of_orders
from {{ ref('jaffle_shop_customers') }} C 
left join {{ ref('base_orders') }} as o
on o.customer_id = C.ID 
group by 1)

select
p.*,
ROW_NUMBER() OVER (ORDER BY p.order_id) as transaction_seq,
ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY p.order_id) as customer_sales_seq,
CASE WHEN c.first_order_date = p.order_placed_at
THEN 'new'
ELSE 'return' END as nvsr,
x.clv_bad as customer_lifetime_value,
c.first_order_date as fdos
FROM paid_orders p
left join customer_orders as c USING (customer_id)
LEFT OUTER JOIN 
(
        select
        p.order_id,
        sum(t2.total_amount_paid) as clv_bad
    from paid_orders p
    left join paid_orders t2 on p.customer_id = t2.customer_id and p.order_id >= t2.order_id
    group by 1
    order by p.order_id
) x on x.order_id = p.order_id
ORDER BY order_id
