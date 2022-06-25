use Project_Host_Behavior_Analysis

/* Torronto dataset*/

/*a. Analyze different metrics to draw the distinction between Super Host and Other Hosts:
To achieve this, you can use the following metrics and explore a few yourself as well. 
Acceptance rate, response rate, instant booking, profile picture, identity verified, review review scores, average no 
of bookings per month, etc. */

/*Below query gives the count of Host and non host*/

select COUNT(*) as Total_super_host from host_toronto_df where host_is_superhost = 'true'

select COUNT(*) as Total_Non_Super_Host from host_toronto_df where host_is_superhost = 'false'

--Total number of Super host are 2353
--Total number of Non super host are 7616

/*Analysis of hosts profile pictures*/

select COUNT(host_id) as Total_Profile_Pic, host_is_superhost,host_has_profile_pic 
from host_toronto_df 
group by host_is_superhost,host_has_profile_pic

--Almost all of the superhosts has the profile picture which is 2351 out of 2353

/*Analysis for instant booking*/

select 
	case 
		when instant_bookable ='true' then 'can be booked' 
		else 'cantbook'
	end as instant_booking,
host_is_superhost, Total_count from 
(select a.host_is_superhost,b.instant_bookable, count(b.host_id) as Total_count
from host_toronto_df as a join listing_toronto_df as b 
on a.host_id = b.host_id
where a.host_is_superhost is not null
group by host_is_superhost, instant_bookable) e1;

--here we can see the list of total number of instant booking availability for super hosts and host 

/*Analysis for average acceptence rate and response rate against host*/
select  Acceptence_rate, Response_rate, 
case
	when host_is_superhost ='true' then 'Super host'
	else 'Host'
	end as host_type
from
(select avg(host_acceptance_rate) as Acceptence_rate, AVG(host_response_rate) as Response_rate, host_is_superhost
from host_toronto_df
where host_acceptance_rate is not null or host_response_rate is not null
group by host_is_superhost) e2

/*Analysis for review scores*/

select round(AVG(b.review_scores_value),2) as Avg_Review_Score, a.host_is_superhost
from host_toronto_df a join listing_toronto_df b 
on a.host_id = b.host_id
group by host_is_superhost


/*Average Rating for listings against host type*/

select round(AVG(a.review_scores_value),2) as Avg_RS_value, round(AVG(a.review_scores_rating),2) as Avg_RS_rating, 
round(AVG(a.review_scores_accuracy),2) as Avg_RS_Accuracy , round(AVG(a.review_scores_checkin),2) as Avg_RS_Checkin,
round(AVG(a.review_scores_cleanliness),2) as Avg_RS_Cleanliness, round(AVG(a.review_scores_communication),2) as Avg_RS_Communication,
case
when b.host_is_superhost = 'true' then 'Super Host' else 'Host' 
end as Host_Type
from listing_toronto_df a join host_toronto_df b 
on a.host_id = b.host_id
where host_is_superhost is not null
group by host_is_superhost
order by host_is_superhost desc

/*Analysis for Identity of super host and host*/

select host_is_superhost, sum(true) as Verified, SUM(false) as Not_Verified
from(
select host_is_superhost,[TRUE],[FALSE] from host_toronto_df
pivot(count(host_id) for host_Identity_verified in ([TRUE],[FALSE]))e3)e4
where host_is_superhost is not null
group by host_is_superhost;




/*b. Using the above analysis, identify top 3 crucial metrics one needs to maintain to become a Super Host and also, find 
their average values.
Three Important Parameters could be Profile Pic, Identity Verified and response/Acceptence rate. Host needs to fulfill these parameter
to become superhost*/
--Identity
select host_is_superhost, sum(true) as Verified, SUM(false) as Not_Verified
from(
select host_is_superhost,[TRUE],[FALSE] from host_toronto_df
pivot(count(host_id) for host_Identity_verified in ([TRUE],[FALSE]))e3)e4
where host_is_superhost is not null
group by host_is_superhost;
--Profile pic
select COUNT(host_id) as Total_Profile_Pic, host_is_superhost,host_has_profile_pic 
from host_toronto_df 
group by host_is_superhost,host_has_profile_pic
--Response rate and Acceptence rate
select  Acceptence_rate, Response_rate, 
case
	when host_is_superhost ='true' then 'Super host'
	else 'Host'
	end as host_type
from
(select avg(host_acceptance_rate) as Acceptence_rate, AVG(host_response_rate) as Response_rate, host_is_superhost
from host_toronto_df
where host_acceptance_rate is not null or host_response_rate is not null
group by host_is_superhost) e2




/*c. Analyze how does the comments of reviewers vary for listings of Super Hosts vs Other Hosts(Extract words from the 
comments provided by the reviewers)*/

/*Extracted positive words: Beautiful, super, clean, wonderful, amazing, recommended, Very welcoming, guest host, perfect, tastefull,welcoming
gracious, great, pleasant, nice, best host

Extracted Negative words: canceled, not recommended, unprofessional, not good, rude, */ 

select case when host_is_superhost = 'true' then 'Super_host' when host_is_superhost = 'false' then 'Host' End as Host_Type, review_count from(
select c.host_is_superhost, COUNT(a.reviewer_id) as review_count
from review_toronto_df as a left join listing_toronto_df as b on a.listing_id = b.id
left join host_toronto_df as c on b.host_id = c.host_id
where a.comments like '%Beautiful%' or a.comments like '%supert%' or a.comments like '%clean%' or a.comments like '%wonderful%' or
a.comments like '%amazing%' or a.comments like '%recommended%' or a.comments like '%Very welcoming%' or a.comments like '%guest host%'
or a.comments like '%perfect%' or a.comments like '%tastefull%' or a.comments like '%tastefull%' or a.comments like '%tastefull%' or a.comments like '%tastefull%'
or a.comments like '%welcoming%' or a.comments like '%gracious%' or a.comments like '%great%' or a.comments like '%pleasant%' or a.comments like '%nice%'
or a.comments like '%best host%' and c.host_is_superhost is not null
group by c.host_is_superhost)e5


/*Extracted Negative words: canceled, not recommended, unprofessional, not good, rude, bad, disappointed, bad experience, tidy */ 

select case when host_is_superhost = 'true' then 'Super_host' when host_is_superhost = 'false' then 'Host' End as Host_Type, review_count from(
select c.host_is_superhost, COUNT(a.reviewer_id) as review_count
from review_toronto_df as a left join listing_toronto_df as b on a.listing_id = b.id
left join host_toronto_df as c on b.host_id = c.host_id
where a.comments like '%canceled%' or a.comments like '%not recommended%' or a.comments like '%unprofessional%' or a.comments like '%not good%' or
a.comments like '%rude%' or a.comments like '%bad%' or a.comments like '%diaappointed%' or a.comments like '%bad experience%'
or a.comments like '%tidy%'  and c.host_is_superhost is not null
group by c.host_is_superhost)e6

/*d. Analyze do Super Hosts tend to have large property types as compared to Other Hosts*/

select top 10 MAX(accommodates) as MAX_Accommodates, property_type from listing_toronto_df
where accommodates > (select AVG(accommodates) from listing_toronto_df)
group by property_type
order by MAX(accommodates) desc;

select count(distinct a.host_id) as Host_Property,
case when a.host_is_superhost = 'true' then 'Super Host' when a.host_is_superhost = 'false' then 'Host' end as 'Host_Type'
from host_toronto_df as a join listing_toronto_df as b on a.host_id = b.host_id
where b.property_type in ('Entire serviced apartment','Entire condominium (condo)','Entire loft','Entire villa','Entire place','Entire rental unit',
'Private room in guesthouse','Entire home','Entire residential home','Entire guest suite')
group by a.host_is_superhost




-- altering datatype
ALTER TABLE listing_toronto_df
ALTER COLUMN accommodates int;

/*e.Analyze the average price and availability of the listings for the upcoming year between Super Hosts and Other Hosts*/

--For Average Price of lisitings for current and upcoming year
select * from(select case when c.host_is_superhost = 'true' then 'Super host'
when c.host_is_superhost = 'false' then 'host'end as Host_Type ,AVG(a.adjusted_price) as AVG_Price, YEAR(Date) as Year
from df_toronto_availability as a join listing_toronto_df as b on a.listing_id = b.id join host_toronto_df as c
on b.host_id = c.host_id
where a.available = 'TRUE' and c.host_is_superhost is not null
group by c.host_is_superhost, YEAR(Date))k
pivot(Avg(Avg_Price) for Host_Type in ([Super host],[host])) as pvt;

--Availability list for current and upcoming year
select * from(select case when c.host_is_superhost = 'true' then 'Super host'
when c.host_is_superhost = 'false' then 'host'end as Host_Type ,
case when a.available = 'TRUE' then 'Available' when a.available = 'FALSE' then 'Not Available' end as Availability,
count(a.id) as Total_Availabitity, Year(Date) as Year
from df_toronto_availability as a join listing_toronto_df as b on a.listing_id = b.id join host_toronto_df as c
on b.host_id = c.host_id
where c.host_is_superhost is not null
group by c.host_is_superhost,a.available,a.listing_id,(Date))k
pivot(sum(Total_Availabitity) for Host_Type in ([Super host],[host])) as pvt;



/*UPDATE df_toronto_availability SET available = 'TRUE' WHERE available = '1';
UPDATE df_toronto_availability SET available = 'FALSE' WHERE available = 0;
case when c.host_is_superhost = 'true' then 'Super host'
when c.host_is_superhost = 'false' then 'host'end as Host_Type*/

ALTER TABLE review_toronto_df
ALTER COLUMN id bigint;

select date from df_toronto_availability


/*f.Analyze if there is some difference in above mentioned trends between Local Hosts or Hosts residing in other locations */

--Considering Local host location and neighbour location same of the listings
select distinct HOST_NAME from(
select a.host_id, a.host_name,b.name, a.host_neighbourhood from host_toronto_df as a join listing_toronto_df as b  on a.host_id = b.host_id
where a.host_neighbourhood = b.neighbourhood_cleansed) e8
where HOST_NAME not in ('??','???');

--Segregating new array for Local Host
select * into Localhost_torronto from (select * from host_toronto_df where HOST_NAME in (select distinct HOST_NAME from(
select a.host_id, a.host_name,b.name, a.host_neighbourhood from host_toronto_df as a join listing_toronto_df as b  on a.host_id = b.host_id
where a.host_neighbourhood = b.neighbourhood_cleansed) e8
where HOST_NAME not in ('??','???'))) e9;
select * from Localhost_torronto;
--Segregating new array for other Host
select * into Otherhost_torronto from (select * from host_toronto_df where HOST_NAME not in (select distinct HOST_NAME from(
select a.host_id, a.host_name,b.name, a.host_neighbourhood from host_toronto_df as a join listing_toronto_df as b  on a.host_id = b.host_id
where a.host_neighbourhood = b.neighbourhood_cleansed) e8
where HOST_NAME not in ('??','???'))) e9;

select * from Otherhost_torronto;

--Response rate and Acceptence Rate of Local Host and Other Host
select round(AVG(host_response_rate),0) as Localhost_Response_rate, round(AVG(host_acceptance_rate),0) as Localhost_Acceptence_rate 
from Localhost_torronto;
select round(AVG(host_response_rate),0) as Otherhost_Response_rate, round(AVG(host_acceptance_rate),0) as Localhost_Acceptence_rate
from Otherhost_torronto;


--Average Price for Local Host and Other Host
Select round(AVG(b.price),2) as Avg_Localhost_Price from Localhost_torronto a join listing_toronto_df b on a.host_id = b.host_id
Select round(AVG(b.price),2) as Avg_Otherhost_Price from Otherhost_torronto a join listing_toronto_df b on a.host_id = b.host_id

--Average Rating for LocalHost and OtherHost

Select round(AVG(b.review_scores_rating),2) as ReviewScore_Localhost 
from Localhost_torronto a join listing_toronto_df b on a.host_id = b.host_id
Select round(AVG(b.review_scores_rating),2) as ReviewScore_Otherhost 
from Otherhost_torronto a join listing_toronto_df b on a.host_id = b.host_id

--Total Number of super host as LocalHost.

select count(*) as Total_SuperHost_LocalHost from(
select * from host_toronto_df where HOST_NAME in
(select a.host_name
from host_toronto_df as a join listing_toronto_df as b on a.host_id = b.host_id
where a.host_neighbourhood = b.neighbourhood_cleansed)) e9
where host_is_superhost = 'true';


--Total Number of host as LocalHost.
select count(*) as Total_Host_Locahost from(
select * from host_toronto_df where HOST_NAME in
(select a.host_name
from host_toronto_df as a join listing_toronto_df as b on a.host_id = b.host_id
where a.host_neighbourhood = b.neighbourhood_cleansed)) e9
where host_is_superhost = 'false';


--Total Number of super host as OtherHost.
select count(*) as Total_SuperHost_OtherHost from(
select * from host_toronto_df where HOST_NAME not in
(select a.host_name
from host_toronto_df as a join listing_toronto_df as b on a.host_id = b.host_id
where a.host_neighbourhood = b.neighbourhood_cleansed)) e9
where host_is_superhost = 'true'

--Total Number of Host as OtherHost.

select count(*) as Total_Host_OtherHost from(
select * from host_toronto_df where HOST_NAME not in
(select a.host_name
from host_toronto_df as a join listing_toronto_df as b on a.host_id = b.host_id
where a.host_neighbourhood = b.neighbourhood_cleansed)) e9
where host_is_superhost = 'false'

-- Verified Profiles for Local Hosts and Other hosts

select count(*) as Total_VerifiedProfiles_LocalHost from Localhost_torronto where host_has_profile_pic = 'true'
select count(*) as Total_NotVerifiedProfiles_LocalHost from Localhost_torronto where host_has_profile_pic = 'false'
select count(*) as Total_VerifiedProfiles_OtherHost from Otherhost_torronto where host_has_profile_pic = 'true'
select count(*) as Total_NotVerifiedProfiles_OtherHost from Otherhost_torronto where host_has_profile_pic = 'false'
--------------------------------------------------------------------------------------------------------------------------------


/*Analyze the above trends for the two cities for which data has been provided and provide insights on comparison*/
--Torronto Host count
select case when host_is_superhost = 'true' then 'Super Host'
when host_is_superhost = 'false' then 'host'end as Torro_Host_Type, count(host_id) as Torro_Total_Count from host_toronto_df 
where host_is_superhost is not null
group by host_is_superhost;
--Vancouver host count
select case when host_is_superhost = 1 then 'Super host'
when host_is_superhost = 0 then 'host'end as Vanco_Host_Type, count(host_id) as Vanco_Total_Count from host_vancouver_df 
where host_is_superhost is not null
group by host_is_superhost;

-- Torronto Profile picture
select COUNT(host_id) as Total_Profile_Pic, case when host_is_superhost = 'true' then 'Super host'
when host_is_superhost = 'false' then 'host'end as Toro_Host_Type,case when host_has_profile_pic = 'true' then 'Has Profile Pic'
when host_has_profile_pic = 'false' then 'No Profile Pic'end as Toro_Profile 
from host_toronto_df 
where host_is_superhost is not null
group by host_is_superhost,host_has_profile_pic;

--Vancouver Profile Picture
select COUNT(host_id) as Total_Profile_Pic_Vanco, case when host_is_superhost = 1 then 'Super host'
when host_is_superhost = 0 then 'host'end as Vanco_Host_Type,case when host_has_profile_pic = 1 then 'Has Profile Pic'
when host_has_profile_pic = 0 then 'No Profile Pic'end as Vanco_Profile
from host_vancouver_df 
where host_is_superhost is not null
group by host_is_superhost,host_has_profile_pic;

/*Analysis for instant booking*/
-- for toronto
select 
	case 
		when instant_bookable ='true' then 'can be booked' 
		else 'cantbook'
	end as instant_booking_Toro,
case when host_is_superhost = 'true' then 'Super host'
when host_is_superhost = 'false' then 'host'end as Toro_Host_Type, Total_count from 
(select a.host_is_superhost,b.instant_bookable, count(b.host_id) as Total_count
from host_toronto_df as a join listing_toronto_df as b 
on a.host_id = b.host_id
where a.host_is_superhost is not null
group by host_is_superhost, instant_bookable) e1;

--for vancouver
select 
	case 
		when instant_bookable =1 then 'can be booked' 
		else 'cantbook'
	end as instant_booking,
case when host_is_superhost = 1 then 'Super host'
when host_is_superhost = 0 then 'host'end as Vanco_Host_Type, Total_count from 
(select a.host_is_superhost,b.instant_bookable, count(b.host_id) as Total_count
from host_vancouver_df as a join listing_vancouver_df as b 
on a.host_id = b.host_id
where a.host_is_superhost is not null
group by host_is_superhost, instant_bookable) e1;

/*Analysis for average acceptence rate and response rate against host*/

-- for toronto
select  Toro_Acceptence_rate, Toro_Response_rate, 
case
	when host_is_superhost ='true' then 'Super host'
	else 'Host'
	end as Toro_host_type
from
(select avg(host_acceptance_rate) as Toro_Acceptence_rate, AVG(host_response_rate) as Toro_Response_rate, host_is_superhost
from host_toronto_df
where host_acceptance_rate is not null or host_response_rate is not null
group by host_is_superhost) e2
--for vancovuer
select  Vanco_Acceptence_rate, Vanco_Response_rate, 
case
	when host_is_superhost =1 then 'Super host'
	else 'Host'
	end as Vanco_host_type
from
(select avg(host_acceptance_rate) as Vanco_Acceptence_rate, AVG(host_response_rate) as Vanco_Response_rate, host_is_superhost
from host_vancouver_df
where host_acceptance_rate is not null or host_response_rate is not null
group by host_is_superhost) e2

/*Analysis for review scores*/
-- for torronto
select round(AVG(b.review_scores_value),2) as Avg_Review_Score_Toro, case when host_is_superhost = 'true' then 'Super host'
when host_is_superhost = 'false' then 'host'end as Toro_Host_Type
from host_toronto_df a join listing_toronto_df b 
on a.host_id = b.host_id
group by host_is_superhost

--for vancovuer
select round(AVG(b.review_scores_value),2) as Avg_Review_Score_Vanco, case
	when a.host_is_superhost =1 then 'Super host'
	when a.host_is_superhost =0 then 'host'
	end as Vanco_host_type
from host_vancouver_df a join listing_vancouver_df b 
on a.host_id = b.host_id
group by host_is_superhost

/*Average Rating for listings against host type*/

--for toronto

select round(AVG(a.review_scores_value),2) as T_Avg_RS_value, round(AVG(a.review_scores_rating),2) as T_Avg_RS_rating, 
round(AVG(a.review_scores_accuracy),2) as T_Avg_RS_Accuracy , round(AVG(a.review_scores_checkin),2) as T_Avg_RS_Checkin,
round(AVG(a.review_scores_cleanliness),2) as T_Avg_RS_Cleanliness, round(AVG(a.review_scores_communication),2) as T_Avg_RS_Communication,
case
when b.host_is_superhost = 'true' then 'Super Host' when b.host_is_superhost = 'false' then 'Host' 
end as Host_Type
from listing_toronto_df a join host_toronto_df b 
on a.host_id = b.host_id
where host_is_superhost is not null
group by host_is_superhost
order by host_is_superhost desc

--for vancovuer

select round(AVG(a.review_scores_value),2) as V_Avg_RS_value, round(AVG(a.review_scores_rating),2) as V_Avg_RS_rating, 
round(AVG(a.review_scores_accuracy),2) as V_Avg_RS_Accuracy , round(AVG(a.review_scores_checkin),2) as V_Avg_RS_Checkin,
round(AVG(a.review_scores_cleanliness),2) as V_Avg_RS_Cleanliness, round(AVG(a.review_scores_communication),2) as V_Avg_RS_Communication,
case
when b.host_is_superhost = 1 then 'Super Host' when b.host_is_superhost = 0 then 'Host'
end as Host_Type
from listing_vancouver_df a join host_vancouver_df b 
on a.host_id = b.host_id
where host_is_superhost is not null
group by host_is_superhost
order by host_is_superhost desc

/*Analysis for Identity of super host and host*/
--For toronto
select host_is_superhost, sum(true) as Verified, SUM(false) as Not_Verified
from(
select host_is_superhost,[TRUE],[FALSE] from host_toronto_df
pivot(count(host_id) for host_Identity_verified in ([TRUE],[FALSE]))e3)e4
where host_is_superhost is not null
group by host_is_superhost;

--For Vancouer
select host_is_superhost, sum(true) as Verified, SUM(false) as Not_Verified
from(
select host_is_superhost,[TRUE],[FALSE] from host_vancouver_df
pivot(count(host_id) for host_Identity_verified in ([TRUE],[FALSE]))e3)e4
where host_is_superhost is not null
group by host_is_superhost

/*b. Using the above analysis, identify top 3 crucial metrics one needs to maintain to become a Super Host and also, find 
their average values.
Three Important Parameters could be Profile Pic, Identity Verified and response/Acceptence rate. Host needs to fulfill these parameter
to become superhost*/
----------------FOR TORONTO------------------
--Identity
select host_is_superhost, sum(true) as Verified, SUM(false) as Not_Verified
from(
select host_is_superhost,[TRUE],[FALSE] from host_toronto_df
pivot(count(host_id) for host_Identity_verified in ([TRUE],[FALSE]))e3)e4
where host_is_superhost is not null
group by host_is_superhost;
--Profile pic
select COUNT(host_id) as Total_Profile_Pic, host_is_superhost,host_has_profile_pic 
from host_toronto_df 
group by host_is_superhost,host_has_profile_pic
--Response rate and Acceptence rate
select  Acceptence_rate, Response_rate, 
case
	when host_is_superhost ='true' then 'Super host'
	else 'Host'
	end as host_type
from
(select avg(host_acceptance_rate) as Acceptence_rate, AVG(host_response_rate) as Response_rate, host_is_superhost
from host_toronto_df
where host_acceptance_rate is not null or host_response_rate is not null
group by host_is_superhost) e2

------------------------------FOR VANCOVUER-----------------------------------
--Identity
select host_is_superhost, sum(true) as Verified, SUM(false) as Not_Verified
from(
select host_is_superhost,[TRUE],[FALSE] from host_vancouver_df
pivot(count(host_id) for host_Identity_verified in ([TRUE],[FALSE]))e3)e4
where host_is_superhost is not null
group by host_is_superhost;
--Profile pic
select COUNT(host_id) as Total_Profile_Pic, host_is_superhost,host_has_profile_pic 
from host_vancouver_df 
group by host_is_superhost,host_has_profile_pic
--Response rate and Acceptence rate
select  Acceptence_rate, Response_rate, 
case
	when host_is_superhost =1 then 'Super host'
	when host_is_superhost =0 then 'host'
	else 'Host'
	end as host_type
from
(select avg(host_acceptance_rate) as Acceptence_rate, AVG(host_response_rate) as Response_rate, host_is_superhost
from host_vancouver_df
where host_acceptance_rate is not null or host_response_rate is not null
group by host_is_superhost) e2

/*c.Analyze how does the comments of reviewers vary for listings of Super Hosts vs Other Hosts(Extract words from the 
comments provided by the reviewers)

Extracted positive words: Beautiful, super, clean, wonderful, amazing, recommended, Very welcoming, guest host, perfect, tastefull,welcoming
gracious, great, pleasant, nice, best host

Extracted Negative words: canceled, not recommended, unprofessional, not good, rude, */ 

------------------------------for toronto---------------------------------------------------------------

select case when host_is_superhost = 'true' then 'Super_host' when host_is_superhost = 'false' then 'Host' End as Host_Type, review_count from(
select c.host_is_superhost, COUNT(a.reviewer_id) as review_count
from review_toronto_df as a left join listing_toronto_df as b on a.listing_id = b.id
left join host_toronto_df as c on b.host_id = c.host_id
where a.comments like '%Beautiful%' or a.comments like '%supert%' or a.comments like '%clean%' or a.comments like '%wonderful%' or
a.comments like '%amazing%' or a.comments like '%recommended%' or a.comments like '%Very welcoming%' or a.comments like '%guest host%'
or a.comments like '%perfect%' or a.comments like '%tastefull%' or a.comments like '%tastefull%' or a.comments like '%tastefull%' or a.comments like '%tastefull%'
or a.comments like '%welcoming%' or a.comments like '%gracious%' or a.comments like '%great%' or a.comments like '%pleasant%' or a.comments like '%nice%'
or a.comments like '%best host%' and c.host_is_superhost is not null
group by c.host_is_superhost)e5

ALTER TABLE review_toronto_df
ALTER COLUMN listing_id int;

---------------------------for vancovuer----------------------------------------------------------

select case when host_is_superhost = 1 then 'Super_host' when host_is_superhost = 0 then 'Host' End as Vanco_Host_Type, Positive_review_count from(
select c.host_is_superhost, COUNT(a.reviewer_id) as Positive_review_count
from review_vancouver_df as a left join listing_vancouver_df as b on a.listing_id = b.id
left join host_vancouver_df as c on b.host_id = c.host_id
where a.comments like '%Beautiful%' or a.comments like '%supert%' or a.comments like '%clean%' or a.comments like '%wonderful%' or
a.comments like '%amazing%' or a.comments like '%recommended%' or a.comments like '%Very welcoming%' or a.comments like '%guest host%'
or a.comments like '%perfect%' or a.comments like '%tastefull%' or a.comments like '%tastefull%' or a.comments like '%tastefull%' or a.comments like '%tastefull%'
or a.comments like '%welcoming%' or a.comments like '%gracious%' or a.comments like '%great%' or a.comments like '%pleasant%' or a.comments like '%nice%'
or a.comments like '%best host%' and c.host_is_superhost is not null
group by c.host_is_superhost)e5

/*Extracted Negative words: canceled, not recommended, unprofessional, not good, rude, bad, disappointed, bad experience, tidy */ 

-------------------------------for toronto-------------------------------------------------------------

select case when host_is_superhost = 'true' then 'Super_host' when host_is_superhost = 'false' then 'Host' End as Host_Type, review_count from(
select c.host_is_superhost, COUNT(a.reviewer_id) as review_count
from review_toronto_df as a left join listing_toronto_df as b on a.listing_id = b.id
left join host_toronto_df as c on b.host_id = c.host_id
where a.comments like '%canceled%' or a.comments like '%not recommended%' or a.comments like '%unprofessional%' or a.comments like '%not good%' or
a.comments like '%rude%' or a.comments like '%bad%' or a.comments like '%diaappointed%' or a.comments like '%bad experience%'
or a.comments like '%tidy%'  and c.host_is_superhost is not null
group by c.host_is_superhost)e6

------------------------------------for vancovuer-------------------------------------------------------

select case when host_is_superhost = 1 then 'Super_host' when host_is_superhost = 0 then 'Host' End as Vanco_Host_Type, Negative_review_count from(
select c.host_is_superhost, COUNT(a.reviewer_id) as Negative_review_count
from review_vancouver_df as a left join listing_vancouver_df as b on a.listing_id = b.id
left join host_vancouver_df as c on b.host_id = c.host_id
where a.comments like '%canceled%' or a.comments like '%not recommended%' or a.comments like '%unprofessional%' or a.comments like '%not good%' or
a.comments like '%rude%' or a.comments like '%bad%' or a.comments like '%diaappointed%' or a.comments like '%bad experience%'
or a.comments like '%tidy%'  and c.host_is_superhost is not null
group by c.host_is_superhost)e6

/*d. Analyze do Super Hosts tend to have large property types as compared to Other Hosts*/

-------------------------------------for toronto----------------------------------------------------------------

select top 10 MAX(accommodates) as Toro_MAX_Accommodates, property_type from listing_toronto_df
where accommodates > (select AVG(accommodates) from listing_toronto_df)
group by property_type
order by MAX(accommodates) desc;

select count(distinct a.host_id) as Toro_Host_Property,
case when a.host_is_superhost = 'true' then 'Super Host' when a.host_is_superhost = 'false' then 'Host' end as 'Host_Type'
from host_toronto_df as a join listing_toronto_df as b on a.host_id = b.host_id
where b.property_type in ('Entire serviced apartment','Entire condominium (condo)','Entire loft','Entire villa','Entire place','Entire rental unit',
'Private room in guesthouse','Entire home','Entire residential home','Entire guest suite')
group by a.host_is_superhost

-------------------------------------for vancovuer---------------------------------------------------------------

select top 10 MAX(accommodates) as Vanco_MAX_Accommodates, property_type from listing_vancouver_df
where accommodates > (select AVG(accommodates) from listing_vancouver_df)
group by property_type
order by MAX(accommodates) desc;

select count(distinct a.host_id) as Vanco_Host_Property,
case when a.host_is_superhost = 1 then 'Super Host' when a.host_is_superhost = 0 then 'Host' end as 'Host_Type'
from host_vancouver_df as a join listing_vancouver_df as b on a.host_id = b.host_id
where b.property_type in ('Entire cabin','Entire home','Entire guest suite','Entire condominium (condo)','Entire place','Entire rental unit',
'Private room in residential home','Entire home','Entire residential home','Entire guest suite','Boat','Entire loft','Entire rental unit')
group by a.host_is_superhost

/*e.Analyze the average price and availability of the listings for the upcoming year between Super Hosts and Other Hosts*/

------------------------------------for torronto-------------------------------------------------------------------------

--For Average Price of lisitings for current and upcoming year
select * from(select case when c.host_is_superhost = 'true' then 'Super host'
when c.host_is_superhost = 'false' then 'host'end as Host_Type ,AVG(a.adjusted_price) as AVG_Price, YEAR(Date) as T_Year
from df_toronto_availability as a join listing_toronto_df as b on a.listing_id = b.id join host_toronto_df as c
on b.host_id = c.host_id
where a.available = 'TRUE' and c.host_is_superhost is not null
group by c.host_is_superhost, YEAR(Date))k
pivot(Avg(Avg_Price) for Host_Type in ([Super host],[host])) as pvt;

------------------------------------for vancovuer-------------------------------------------------------------------------

--For Average Price of lisitings for current and upcoming year
select * from(select case when c.host_is_superhost = 1 then 'Super host'
when c.host_is_superhost = 0 then 'host'end as Host_Type ,AVG(a.adjusted_price) as AVG_Price, YEAR(Date) as V_Year
from df_vancouver_availability as a join listing_vancouver_df as b on a.listing_id = b.id join host_vancouver_df as c
on b.host_id = c.host_id
where a.available = 1 and c.host_is_superhost is not null
group by c.host_is_superhost, YEAR(Date))k
pivot(Avg(Avg_Price) for Host_Type in ([Super host],[host])) as pvt;

---------------------------------------for toronto------------------------------------------------------------------------

--Availability list for current and upcoming year
select * from(select case when c.host_is_superhost = 'true' then 'Super host'
when c.host_is_superhost = 'false' then 'host'end as Host_Type ,
case when a.available = 'TRUE' then 'Available' when a.available = 'FALSE' then 'Not Available' end as T_Availability,
count(a.id) as Total_Availabitity, Year(Date) as Year
from df_toronto_availability as a join listing_toronto_df as b on a.listing_id = b.id join host_toronto_df as c
on b.host_id = c.host_id
where c.host_is_superhost is not null
group by c.host_is_superhost,a.available,a.listing_id,(Date))k
pivot(sum(Total_Availabitity) for Host_Type in ([Super host],[host])) as pvt;

--------------------------------------for vancover----------------------------------------------------------------------------

select * from(select case when c.host_is_superhost = 1 then 'Super host'
when c.host_is_superhost = 0 then 'host'end as Host_Type ,
case when a.available = 1 then 'Available' when a.available = 0 then 'Not Available' end as V_Availability,
count(a.id) as Total_Availabitity, Year(Date) as Year
from df_vancouver_availability as a join listing_vancouver_df as b on a.listing_id = b.id join host_vancouver_df as c
on b.host_id = c.host_id
where c.host_is_superhost is not null
group by c.host_is_superhost,a.available,a.listing_id,(Date))k
pivot(sum(Total_Availabitity) for Host_Type in ([Super host],[host])) as pvt;


/*f.Analyze if there is some difference in above mentioned trends between Local Hosts or Hosts residing in other locations */

--------------------------------------for toronto------------------------------------------------------------------------------

--Considering Local host location and neighbour location same of the listings
select distinct HOST_NAME as Toro_Host_Name from(
select a.host_id, a.host_name,b.name, a.host_neighbourhood from host_toronto_df as a join listing_toronto_df as b  on a.host_id = b.host_id
where a.host_neighbourhood = b.neighbourhood_cleansed) e8
where HOST_NAME not in ('??','???');

---------------------------------------for vancovuer-------------------------------------------------------------------------
--Considering Local host location and neighbour location same of the listings
select distinct HOST_NAME as Vanco_Host_Name from(
select a.host_id, a.host_name,b.name, a.host_neighbourhood from host_vancouver_df as a join listing_vancouver_df as b  on a.host_id = b.host_id
where a.host_neighbourhood = b.neighbourhood_cleansed) e8
where HOST_NAME not in ('??','???');

----------------------------------for toronto-----------------------------------------------------------
--Segregating new array for Local Host
select * into Localhost_torronto from (select * from host_toronto_df where HOST_NAME in (select distinct HOST_NAME from(
select a.host_id, a.host_name,b.name, a.host_neighbourhood from host_toronto_df as a join listing_toronto_df as b  on a.host_id = b.host_id
where a.host_neighbourhood = b.neighbourhood_cleansed) e8
where HOST_NAME not in ('??','???'))) e9;

-----------------------------------for vancouer----------------------------------------------------------------
--Segregating new array for Local Host
select * into Localhost_Vancouver from (select * from host_vancouver_df where HOST_NAME in (select distinct HOST_NAME from(
select a.host_id, a.host_name,b.name, a.host_neighbourhood from host_vancouver_df as a join listing_vancouver_df as b  on a.host_id = b.host_id
where a.host_neighbourhood = b.neighbourhood_cleansed) e8
where HOST_NAME not in ('??','???'))) e9;
----Segregating new array for Other Host
select * into Otherhost_Vancouver from (select * from host_vancouver_df where HOST_NAME not in (select distinct HOST_NAME from(
select a.host_id, a.host_name,b.name, a.host_neighbourhood from host_vancouver_df as a join listing_vancouver_df as b  on a.host_id = b.host_id
where a.host_neighbourhood = b.neighbourhood_cleansed) e8
where HOST_NAME not in ('??','???'))) e9;

select * from Localhost_Vancouver;
select * from Otherhost_Vancouver;

--------------------------------------for toronto----------------------------------------------------------------------
--Response rate and Acceptence Rate of Local Host and Other Host
select round(AVG(host_response_rate),0) as T_Localhost_Response_rate, round(AVG(host_acceptance_rate),0) as T_Localhost_Acceptence_rate 
from Localhost_torronto;
select round(AVG(host_response_rate),0) as T_Otherhost_Response_rate, round(AVG(host_acceptance_rate),0) as T_Otherhost_Acceptence_rate
from Otherhost_torronto;

-------------------------------------for vancouver----------------------------------------------------------------------------------
--Response rate and Acceptence Rate of Local Host and Other Host
select round(AVG(host_response_rate),0) as V_Localhost_Response_rate, round(AVG(host_acceptance_rate),0) as V_Localhost_Acceptence_rate 
from Localhost_Vancouver;
select round(AVG(host_response_rate),0) as V_Otherhost_Response_rate, round(AVG(host_acceptance_rate),0) as V_Localhost_Acceptence_rate
from Otherhost_Vancouver;

--Average Price for Local Host and Other Host
-------------------------------------for toronto-----------------------------------------------------------------------------------
Select round(AVG(b.price),2) as T_Avg_Localhost_Price from Localhost_torronto a join listing_toronto_df b on a.host_id = b.host_id
Select round(AVG(b.price),2) as T_Avg_Otherhost_Price from Otherhost_torronto a join listing_toronto_df b on a.host_id = b.host_id

--Average Price for Local Host and Other Host
-------------------------------------for Vancouer-----------------------------------------------------------------------------------
Select round(AVG(b.price),2) as V_Avg_Localhost_Price from Localhost_Vancouver a join listing_vancouver_df b on a.host_id = b.host_id
Select round(AVG(b.price),2) as V_Avg_Otherhost_Price from Otherhost_Vancouver a join listing_vancouver_df b on a.host_id = b.host_id

--Average Rating for LocalHost and OtherHost
------------------------------------for toronto-----------------------------------------------------------------------------------
Select round(AVG(b.review_scores_rating),2) as T_ReviewScore_Localhost 
from Localhost_torronto a join listing_toronto_df b on a.host_id = b.host_id
Select round(AVG(b.review_scores_rating),2) as T_ReviewScore_Otherhost 
from Otherhost_torronto a join listing_toronto_df b on a.host_id = b.host_id
------------------------------------for vancouver-----------------------------------------------------------------------------------
Select round(AVG(b.review_scores_rating),2) as V_ReviewScore_Localhost 
from Localhost_Vancouver a join listing_vancouver_df b on a.host_id = b.host_id
Select round(AVG(b.review_scores_rating),2) as V_ReviewScore_Otherhost 
from Otherhost_Vancouver a join listing_vancouver_df b on a.host_id = b.host_id

--Total Number of super host as LocalHost.
-------------------------------------for toronto-------------------------------------------------------------------------------------
select count(*) as T_Total_SuperHost_LocalHost from(
select * from host_toronto_df where HOST_NAME in
(select a.host_name
from host_toronto_df as a join listing_toronto_df as b on a.host_id = b.host_id
where a.host_neighbourhood = b.neighbourhood_cleansed)) e9
where host_is_superhost = 'true';

--Total Number of super host as LocalHost.
-------------------------------------for Vancouer--------------------------------------------------------------------------------------
select count(*) as V_Total_SuperHost_LocalHost from(
select * from host_vancouver_df where HOST_NAME in
(select a.host_name
from host_vancouver_df as a join listing_vancouver_df as b on a.host_id = b.host_id
where a.host_neighbourhood = b.neighbourhood_cleansed)) e9
where host_is_superhost = 'true';


--Total Number of host as LocalHost.
---------------------------------------for toronto-----------------------------------------------------------------------------------------
select count(*) as T_Total_Host_Locahost from(
select * from host_toronto_df where HOST_NAME in
(select a.host_name
from host_toronto_df as a join listing_toronto_df as b on a.host_id = b.host_id
where a.host_neighbourhood = b.neighbourhood_cleansed)) e9
where host_is_superhost = 'false';

--Total Number of host as LocalHost.
---------------------------------------for Vancouver----------------------------------------------------------------------------------------
select count(*) as V_Total_Host_Locahost from(
select * from host_vancouver_df where HOST_NAME in
(select a.host_name
from host_vancouver_df as a join listing_vancouver_df as b on a.host_id = b.host_id
where a.host_neighbourhood = b.neighbourhood_cleansed)) e9
where host_is_superhost = 0;


--Total Number of super host as OtherHost.
---------------------------------------for toronto-------------------------------------------------------------------------------------------
select count(*) as T_Total_SuperHost_OtherHost from(
select * from host_toronto_df where HOST_NAME not in
(select a.host_name
from host_toronto_df as a join listing_toronto_df as b on a.host_id = b.host_id
where a.host_neighbourhood = b.neighbourhood_cleansed)) e9
where host_is_superhost = 'true'

------------------------------------------for vancouer------------------------------------------------------------------------
select count(*) as V_Total_SuperHost_OtherHost from(
select * from host_vancouver_df where HOST_NAME not in
(select a.host_name
from host_vancouver_df as a join listing_vancouver_df as b on a.host_id = b.host_id
where a.host_neighbourhood = b.neighbourhood_cleansed)) e9
where host_is_superhost = 1


--Total Number of Host as OtherHost.
-----------------------------------------------for torronto---------------------------------------------------------------------------

select count(*) as T_Total_Host_OtherHost from(
select * from host_toronto_df where HOST_NAME not in
(select a.host_name
from host_toronto_df as a join listing_toronto_df as b on a.host_id = b.host_id
where a.host_neighbourhood = b.neighbourhood_cleansed)) e9
where host_is_superhost = 'false'

------------------------------------------------for Vancouer----------------------------------------------------------------------------

select count(*) as V_Total_Host_OtherHost from(
select * from host_vancouver_df where HOST_NAME not in
(select a.host_name
from host_vancouver_df as a join listing_vancouver_df as b on a.host_id = b.host_id
where a.host_neighbourhood = b.neighbourhood_cleansed)) e9
where host_is_superhost = 0;

-- Verified Profiles for Local Hosts and Other hosts
------------------------------------------------for toronto-------------------------------------------------------------------------------
select count(*) as T_Total_VerifiedProfiles_LocalHost from Localhost_torronto where host_has_profile_pic = 'true'
select count(*) as T_Total_NotVerifiedProfiles_LocalHost from Localhost_torronto where host_has_profile_pic = 'false'
select count(*) as T_Total_VerifiedProfiles_OtherHost from Otherhost_torronto where host_has_profile_pic = 'true'
select count(*) as T_Total_NotVerifiedProfiles_OtherHost from Otherhost_torronto where host_has_profile_pic = 'false'
-----------------------------------------------for vancover------------------------------------------------------------------------------
select count(*) as V_Total_VerifiedProfiles_LocalHost from Localhost_Vancouver where host_has_profile_pic = 1
select count(*) as V_Total_NotVerifiedProfiles_LocalHost from Localhost_Vancouver where host_has_profile_pic = 0
select count(*) as V_Total_VerifiedProfiles_OtherHost from Otherhost_Vancouver where host_has_profile_pic = 1
select count(*) as V_Total_NotVerifiedProfiles_OtherHost from Otherhost_Vancouver where host_has_profile_pic = 0































/*select AVg(a.host_response_rate) As Local_Response_rate, AVG(b.host_response_rate) as Other_response_rate
from Localhost_torronto a join Otherhost_torronto b on a.host_id = b.host_id
where a.host_response_rate is not null or b.host_response_rate is not null*/






















