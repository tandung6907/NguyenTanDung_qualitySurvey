-- PHAN I
create database quality_survey_2; -- tạo database 
set sql_safe_updates = 0; -- tắt mode an toàn của sql để có thể xóa hoặc cập nhật

use quality_survey_2; -- dùng database vừa tạo

-- Tạo bảng
create table teams(
	team_id 		varchar(5) 			primary key,
    team_name 		varchar(100) 		not null,
    stadium 		varchar(100) 		not null,
    coach 			varchar(100) 		not null,
    market_value 	decimal(15,2) 		not null,
    `status` 		varchar(20)    		not null,
    
    constraint chk_tx_status
    check (`status` in ('Active', 'Suspended', 'Relegated')) 
);

create table players(
	player_id 		varchar(5) 			primary key,
	full_name 		varchar(100) 		not null,
    `position` 		varchar(50) 		not null,
    nationality 	varchar(50) 		not null,
    team_id  		varchar(5) 			not null,
    salary 			decimal(15,2) 		not null,
    
    constraint fk_tx_team
    foreign key (team_id) references teams(team_id)
    on delete cascade
);

create table matches(
	match_id 		int 				primary key auto_increment,
    team_id  		varchar(5) 			not null,
    opponent_name  	varchar(100) 		not null,
    match_date 		datetime 			not null,
    ticket_sold 	int,
    
    constraint fk_tx_teams
    foreign key (team_id) references teams(team_id)
);

create table statistics(
	stat_id 		int 				primary key auto_increment,
    match_id 		int 				not null,
    player_id 		varchar(5) 			not null,
    goals 			int 				not null,
    assists 		int 				not null,
    
    constraint fk_tx_matches
    foreign key (match_id) references matches(match_id),
    
    constraint fk_tx_player
    foreign key (player_id) references players(player_id)
);

-- Yêu cầu bổ sung
-- Thêm ràng buộc cho cột market_value: giá trị đội hình phải lớn hơn 0.
alter table teams
add constraint chk_tx_market_value
check (market_value > 0);

-- Thiết lập giá trị mặc định cho cột status là 'Active'.
alter table teams
modify `status` 	varchar(20) 		not null default 'Active';

-- Thêm cột birth_year (INT) vào bảng Players.
alter table players
add column birth_year 	int 			not null;


-- PHAN II - Chèn dữ liệu và Thao tác
insert into teams (team_id, team_name, stadium, coach, market_value, `status`)
values
	('T01', 'Manchester City', 'Etihad', 'Pep Guardiola', 1200000000.00, 'Active'), 
	('T02', 'Arsenal', 'Emirates', 'Mikel Arteta', 1100000000.00, 'Active'), 
	('T03', 'Liverpool', 'Anfield', 'Arne Slot', 900000000.00, 'Active'), 
	('T04', 'Manchester United', 'Old Trafford', 'Erik ten Hag', 850000000.00, 'Suspended'), 
	('T05', 'Chelsea', 'Stamford Bridge', 'Enzo Maresca', 950000000.00, 'Active');  

insert into players (player_id, full_name, position, nationality, team_id, salary, birth_year)
values
	('P01', 'Erling Haaland', 'Tiền đạo', 'Na Uy', 'T01', 400000.00, 2000), 
	('P02', 'Bukayo Saka', 'Tiền vệ', 'Anh', 'T02', 300000.00, 2001), 
	('P03', 'Mohamed Salah', 'Tiền đạo', 'Ai Cập', 'T03', 350000.00, 1992), 
	('P04', 'Bruno Fernandes', 'Tiền vệ', 'Bồ Đào Nha', 'T04', 250000.00, 1994), 
	('P05', 'Cole Palmer', 'Tiền đạo', 'Anh', 'T05', 150000.00, 2002);   

insert into matches (match_id, team_id, opponent_name, match_date, ticket_sold)
values
	(1, 'T01', 'Arsenal', '2025-11-10 20:00:00', 55000), 
	(2, 'T03', 'Manchester United', '2025-11-12 18:30:00', 60000), 
	(3, 'T05', 'Manchester City', '2025-11-15 22:00:00', 40000), 
	(4, 'T02', 'Liverpool', '2025-12-01 21:00:00', 60000);

insert into statistics (stat_id, match_id, player_id, goals, assists)
values 
	(1, 1, 'P01', 2, 0),
	(2, 1, 'P02', 1, 1), 
	(3, 2, 'P03', 1, 0), 
	(4, 3, 'P01', 1, 0),
	(5, 3, 'P05', 0, 1);  

-- Yêu cầu cập nhật/xóa:
-- Cập nhật coach của đội bóng 'T04' thành 'Ruud van Nistelrooy'.
update teams
set coach = 'Ruud van Nistelrooy'
where team_id = 'T04';

-- Tăng lương tuần (salary) thêm 10% cho tất cả cầu thủ có quốc tịch 'Anh'.
update players
set salary = salary * 1.1
where nationality = 'Anh';

-- Xóa các thống kê (Statistics) của cầu thủ không ghi bàn và không kiến tạo (goals = 0 và assists = 0).
delete from statistics
where goals = 0 and assists = 0;

-- Cập nhật status của các đội bóng có giá trị đội hình dưới 900,000,000 thành 'Relegated'. 
update teams
set `status` = 'Relegated'
where market_value < 900000000;

-- Cập nhật ticket_sold thành 0 cho các trận đấu diễn ra trong tháng 11/2025 mà số vé đang để trống (NULL).
update matches
set ticket_sold = 0
where (month(match_date) = 11 and year(match_date) = 2025) and ticket_sold is null;


-- PHAN III - Truy vấn dữ liệu
-- Cơ bản
-- Liệt kê các cầu thủ có mức lương tuần từ 200,000 đến 400,000 Euro.
select 
	full_name 			as 'Tên Cầu Thủ',
    salary 				as 'Lương'
from players 
where salary between 200000 and 400000;

-- Lấy full_name, position của cầu thủ có họ 'b'.
select 
	full_name 			as 'Tên Cầu Thủ',
	`position` 			as 'Vị Trí Chơi Bóng'
from players 
where full_name like 'b%';

-- Hiển thị team_name, stadium, sắp xếp theo market_value giảm dần.
select 
	team_name 			as 'Tên Đội Bóng',
    stadium 			as 'Sân Vận Động',
    market_value 		as 'Tổng giá trị cả đội'
from teams
order by market_value desc;

-- Lấy ra 3 cầu thủ trẻ nhất (dựa trên birth_year).
select 
	full_name 			as 'Tên Cầu Thủ',
    birth_year 			as 'Năm Sinh'
from players
order by birth_year desc
limit 3;

-- Hiển thị danh sách các trận đấu diễn ra trong tháng 11/2025.
select 
	t.team_name 		as 'Tên Đội',
    m.opponent_name 	as 'Địch Thủ',
    m.match_date 		as 'Ngày Đá'
from matches m
join teams t on m.team_id = t.team_id
where month(match_date) = 11 and year(match_date) = 2025;

-- Tìm đội bóng có tên bắt đầu bằng 'Man' hoặc kết thúc bằng 'City'.
select
	team_name 			as 'Tên Đội',
    stadium 			as 'Sân Nhà',
    coach 				as 'HLV'
from teams
where team_name like 'Man%' or team_name like '%City';

-- Lấy thông tin cầu thủ có số bàn thắng trong một trận đấu từ 1 đến 3 bàn.
select 
	p.full_name 		as 'Tên Cầu Thủ',
	t.team_name 		as 'Đội',
    s.goals 			as 'Số Bàn Thắng' 
from statistics s
join players p on s.player_id = p.player_id
join teams t   on t.team_id   = p.team_id
where s.goals between 1 and 3;

-- Sắp xếp danh sách đội bóng theo tên sân vận động (stadium) từ A-Z.
select
	team_name 			as 'Tên Đội Bóng',
    stadium 			as 'Sân Nhà',
    coach 				as 'HLV'
from teams
order by stadium asc;


-- Nâng cao
-- Hiển thị match_id, full_name (cầu thủ), goals, match_date của các cầu thủ thuộc quốc tịch 'Na Uy'.
select 
    m.match_id          as 'Mã Trận Đấu',
    t.team_name         as 'Tên Đội',
    p.full_name         as 'Tên Cầu Thủ',
    s.goals             as 'Bàn Thắng',
    m.match_date        as 'Ngày Thi Đấu'
from statistics s
join matches m on m.match_id  = s.match_id
join players p on p.player_id = s.player_id
join teams t   on t.team_id   = p.team_id
where p.nationality = 'Na Uy';

-- Thống kê mỗi quốc tịch (nationality) hiện có bao nhiêu cầu thủ trong giải đấu.
select 
	nationality 		as 'Quốc Tịch',
    count(player_id) 	as 'Số Lượng Cầu Thủ'
from players
group by nationality;

-- Liệt kê tên đội bóng và tổng số trận đấu mà họ đã tham gia với tư cách là đội chủ nhà hiển thị cả đội chưa đá trận chủ nhà nào.
select
	t.team_name 				as 'Tên Đội Bóng',
    count(m.match_id)			as 'Số Lần Làm Chủ Nhà'
from teams t
left join matches m on t.team_id = m.team_id
group by t.team_name;

-- Tìm các cầu thủ chưa từng ghi bàn hoặc kiến tạo trong bất kỳ trận đấu nào.
select 
	p.full_name 		as 'Tên Cầu Thủ'
from players p
left join statistics s on p.player_id = s.player_id
where s.stat_id is null;

-- Tính tổng số tiền lương tuần mà mỗi đội bóng phải chi trả dựa trên danh sách cầu thủ hiện có.
select
	t.team_name 		as 'Tên Đội Bóng',
    sum(p.salary) 		as 'Tổng Lương Cầu Thủ'
from teams t
join players p on t.team_id = p.team_id
group by t.team_name;

-- Hiển thị tên các cầu thủ đã từng ghi bàn trong từ 2 trận đấu khác nhau trở lên.
select
    p.full_name         as 'Tên Cầu Thủ',
    count(distinct s.match_id) as 'Số Trận Có Bàn Thắng'
from statistics s
join players p on p.player_id = s.player_id
where s.goals > 0
group by p.player_id, p.full_name
having count(distinct s.match_id) >= 2;

-- Tìm cầu thủ có mức lương tuần cao nhất giải đấu.
select
    full_name           as 'Tên Cầu Thủ',
    nationality         as 'Quốc Tịch',
    salary              as 'Lương Tuần'
from players
order by salary desc
limit 1;

-- Liệt kê thông tin các trận đấu có sự tham gia của đội 'Manchester City' và có số vé bán ra trên 50,000.
select
    m.match_id          as 'Mã Trận',
    t.team_name         as 'Đội Chủ Nhà',
    m.opponent_name     as 'Đối Thủ',
    m.match_date        as 'Ngày Thi Đấu',
    m.ticket_sold       as 'Vé Đã Bán'
from matches m
join teams t on t.team_id = m.team_id
where t.team_name = 'Manchester City'
  and m.ticket_sold > 50000;