CREATE TABLE patches (
    order_applied smallint unsigned not null unique auto_increment,
    patch varchar(100) not null primary key,
    date_applied timestamp not null default current_timestamp,
    who_applied varchar(50) not null
);

create table patch_changelog (
    patch varchar(100) not null,
    table_name varchar(100) not null,
    type enum('create','drop','alter'),
    primary key (patch, table_name, type),
    foreign key (patch) references patches (patch),
    unique key (patch, table_name)
);

create view patch_history as 
select order_applied, patches.patch, table_name, type from patch_changelog 
inner join patches on patch_changelog.patch=patches.patch 
order by order_applied;
