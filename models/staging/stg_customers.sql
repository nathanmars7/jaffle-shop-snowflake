-- Staging model: 1-to-1 with the raw customers seed.
-- Only light cleanup happens here: renaming columns to clear, consistent names.

with source as (

    select * from {{ ref('raw_customers') }}

),

renamed as (

    select
        id as customer_id,
        first_name,
        last_name

    from source

)

select * from renamed
