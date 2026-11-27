#视频时长与互动量
select
    case
    when cast(substring_index(视频时长,'分',1) as unsigned ) <= 3 then '3分钟以内'
    when cast(substring_index(视频时长,'分',1) as unsigned ) between 3 and 6 then '3-6分钟'
    when cast(substring_index(视频时长,'分',1) as unsigned ) between 7 and 10 then '7-10分钟'
else '10分钟以上'
end as time_group,
count(*) as video_mount,
round(avg(点赞数+评论数+分享数+收藏数),0) as avg_total_engagements,
concat(round(sum(分享数) / sum(点赞数 + 评论数 + 分享数 + 收藏数) * 100, 2),'%') AS share_ratio_pct
from douyin
group by time_group
order by avg_total_engagements desc;

#不同标签数量对互动流量影响
select
    case
        when length(文本标签)-length(replace(文本标签,',','')+1) between 0 and 2 then '0-2个标签'
        when length(文本标签)-length(replace(文本标签,',','')+1) between 3 and 5 then '3-5个标签'
        when length(文本标签)-length(replace(文本标签,',','')+1) > 5 then '5个以上标签'
end as title_group,
    round(avg(点赞数+评论数+分享数+收藏数),0) as avg_total_engagements,
    concat(round(sum(分享数) / sum(点赞数 + 评论数 + 分享数 + 收藏数) * 100, 2),'%') AS share_ratio_pct
from douyin
group by title_group
order by avg_total_engagements desc;

#不同类型标题对视频影响
select
    '带数字' as title_type,
    count(*) as video_mount,
    round(avg(点赞数+评论数+分享数+收藏数),0) as avg_total_engagements,
    concat(round(sum(分享数) / sum(点赞数 + 评论数 + 分享数 + 收藏数) * 100, 2),'%') AS share_ratio_pct
from douyin where 视频标题 regexp '[0-9]'
union all
select
    '带疑问(?)' as title_type,
    count(*) as video_mount,
     round(avg(点赞数+评论数+分享数+收藏数),0) as avg_total_engagements,
     concat(round(sum(分享数) / sum(点赞数 + 评论数 + 分享数 + 收藏数) * 100, 2),'%') AS share_ratio_pct
from douyin where 视频标题 like '%?%' or  视频标题 like '%？%'
union all
select
    '带感叹(!)' as title_type,
    count(*) as video_mount,
     round(avg(点赞数+评论数+分享数+收藏数),0) as avg_total_engagements,
     concat(round(sum(分享数) / sum(点赞数 + 评论数 + 分享数 + 收藏数) * 100, 2),'%') AS share_ratio_pct
from douyin where 视频标题 like '%!%'
union all
select
    '普通标题' AS title_type,
    count(*) AS video_count,
    round(AVG(点赞数 + 评论数 + 分享数 + 收藏数), 0) AS avg_total_engagements,
    concat(round(sum(分享数) / sum(点赞数 + 评论数 + 分享数 + 收藏数) * 100, 2),'%') AS share_ratio_pct
FROM douyin
WHERE 视频标题 NOT REGEXP '[0-9]' AND 视频标题 NOT LIKE '%?%' AND 视频标题 NOT LIKE '%？%'
order by avg_total_engagements desc;

#不同视频类型
select 视频类型,
       count(*) as video_mount,
       round(AVG(点赞数 + 评论数 + 分享数 + 收藏数), 0) AS avg_total_engagements,
       concat(round(sum(分享数) / sum(点赞数 + 评论数 + 分享数 + 收藏数) * 100, 2),'%') AS share_ratio_pct
from douyin
group by 视频类型
order by avg_total_engagements desc;

#不同地区
with region as (
    select
        省份名称,
        视频类型,
        round(AVG(点赞数 + 评论数 + 分享数 + 收藏数), 0) AS avg_total_engagements,
        rank() over (partition by 省份名称 order by AVG(点赞数 + 评论数 + 分享数 + 收藏数) desc) as rk
    from douyin
    group by 省份名称,视频类型
    having count(*)>=5
)
select * from region where rk=1 order by avg_total_engagements desc;