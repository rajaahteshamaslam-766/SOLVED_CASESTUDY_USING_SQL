# Q no1. Find the busiest airport by the number of flights take off.
with busiest_airport as(
select a.name as airport_name,count(*) as total_flights,
dense_rank()over(order by count(*)desc) as ranking
from flights as f
inner join 
airports as a
on f.Origin=a.AirportID
group by a.name
order by total_flights desc)
select airport_name,total_flights from 
busiest_airport where ranking=1;

#Q no 1.1. Find the number of flights take off from each airport.
select a.name as airport_name,count(*) as total_flights,
dense_rank()over(order by count(*) desc) as ranking
from flights as f
inner join 
airports as a
on f.Origin=a.AirportID
group by a.name
order by total_flights desc;

# Q no. 2 Total number of tickets sold per airline.
select a.Name as airline_name,count(*) as total_tickets from
tickets t inner join 
flights f 
on t.FlightID=f.FlightID
inner join airlines a 
on f.AirlineID=a.AirlineID
group by a.name
order by total_tickets desc;

# Q no. 3 List all flights operated by 'emirates' with airport names (origin,destination)
select a.Name as flight_name,p.name as Original_airport,p1.Name as destinational_airport
from
airlines a inner join
flights f on
a.airlineid=f.AirlineID
inner join airports p
on p.AirportID=f.Origin
inner join airports p1
on p1.AirportID=f.Destination
where a.Name='Emirates';

# Q no.3.1 Find  departure time for emirates's airlines's flights from a specific airport(e.g Dubai international airport) to other airport.
select a.name, ap.name as airport,f.DepartureTime,ap.name as origin,ap1.name as destination
from
airlines a 
inner join
flights f 
on a.AirlineID=f.AirlineID
inner join 
airports ap 
on ap.AirportID=f.origin
inner join
airports ap1
on ap1.AirportID=f.Destination
where 
a.Name='Emirates' and ap.Name='Dubai International airport';

#Qno.4 For each airport, show the top airline by number of flights departing from there.

select  a.name as airline_name,ap.name as airport,count(*) as no_of_flights
from 
airports ap inner join
flights f 
on 
ap.AirportID=f.Origin
inner join
airports ap1 
on
ap1.AirportID=f.Destination
inner join 
airlines a 
on
a.AirlineID=f.AirlineID
group by airline_name,airport
order by no_of_flights desc;

#Q no.5 For each flight , show time taken in hours and categorize it as short(<2),medium(2-5h) ,and long(>5h).
select flightid, DepartureTime,ArrivalTime,
datediff(minute,departuretime,arrivaltime)/60 as duration_hrs,
case
when datediff(minute,departuretime,arrivaltime) < 120 then 'Short'
when datediff(minute,departuretime,arrivaltime) <= 300 then 'Medium'
else 'Long'
end as flightcategory
from flights;

#Q no.6 Show each passenger's flight dates .
select p.name as Passenger_Name,date(f.DepartureTime),p.PassengerID
from passengers p
inner join
tickets t 
on p.passengerId=t.passengerId
inner join
flights f
on f.FlightID=t.FlightID
group by p.PassengerID, Passenger_Name,date(f.DepartureTime);

#Q no.6.1 Show each passenger's first and last flight date and total flights.

select p.PassengerID,p.name as Passenger_Name,min(date(f.DepartureTime)) as first_flight,max(date(f.DepartureTime)) as last_flight,
count(*) as total_flight
from passengers p
inner join
tickets t 
on p.passengerId=t.passengerId
inner join
flights f
on f.FlightID=t.FlightID
group by p.PassengerID, Passenger_Name;

# Q no.7 Find the flights with the highest price ticket sold for each route(origin - destination).
select f.FlightID,ap.name as origin,ap1.name as destination,max(t.Price) as ticket_price
from tickets
t inner join
flights f
on f.FlightID=t.FlightID
inner join 
airports ap
on ap.AirportID=f.Origin
inner join
airports ap1
on ap1.airportid=f.destination
group by f.FlightID,origin,destination
order by ticket_price desc;

# Q no.8 Find the highest spending passenger in each frequent Flyer status group.
with cte_spending as(
select * ,
rank () over(partition by FrequentFlyerStatus order by total_spent desc) as rn
from(
select p.PassengerID,p.name,p.FrequentFlyerStatus,sum(t.Price) as total_spent
from passengers p
inner join 
tickets t 
on p.PassengerID=t.PassengerID
group by p.PassengerID,p.name,p.FrequentFlyerStatus) t) 

select name,frequentflyerstatus,total_spent
from cte_spending
where rn=1 
;

#Q no 9. Find total revenue and number of tickets sold for each airline, and rank the airline base on total revenue.
with cte_revenue as  (
select f.AirlineID, a.name as airline_name,count(t.TicketID) as no_of_tickets,sum(t.Price) as total_revenue
from tickets t 
inner join 
flights f
on f.FlightID=t.FlightID
inner join 
airlines a 
on 
f.airlineID=a.AirlineID
group by f.airlineid,a.name)
select airlineId,airline_name,no_of_tickets,total_revenue,
rank()over(order by total_revenue desc) as revenuerank
from cte_revenue;

#Q no.10 For each passenger identify their most frequently used airline. If a passenger has multiple airlines with the same highest usage
# show all suh airlines.
select p.name as passenger_name,a.name as airline_name,count(*) as travel_count
from 
passengers p
inner join 
tickets t 
on p.passengerId=t.PassengerID
inner join
flights f 
on f.FlightID=t.FlightID
inner join 
airlines a
on 
f.airlineid=a.AirlineID
group by p.Name,a.name;


