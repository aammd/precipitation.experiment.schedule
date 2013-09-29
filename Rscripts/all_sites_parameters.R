## code for calculating site characteristics
## first read in all data:

library(plyr)
sites <- c("Cardoso","Colombia","CostaRica","FrenchGuiana","Macae")

scheduleread <- function(x){
  path <- file.path(getwd(),"Experimental.Schedules",x)
  filepath <- list.files(path=path,pattern="schedule.csv",full.names=TRUE)
  read.csv(filepath,na.strings=c("NA","insects","sample"))
}


all_schedules <- lapply(sites,scheduleread)
names(x=all_schedules) <- sites

analyzeNumbers <- function(x){
  numeric_names <- grepl(pattern=".[0-9]",x=names(x))
  mean_rain <- apply(X=x[,numeric_names],MARGIN=1,mean,na.rm=TRUE)
  data.frame(x[,!numeric_names],meanwater=mean_rain)
}

## using ddply
meltByName <- function(x){
  numeric_names <- grepl(pattern=".[0-9]",x=names(x))
  melt(data=x,id.vars=names(x)[!numeric_names])
}
# melt first
library(reshape2)
all_sched_melt <- lapply(all_schedules,meltByName)
# then wrap ddply in ldply

trt_summaries <- function(df){
  ddply(.data=df,.variables=.(trt.name),
        summarize,
        ## any summary statistic you like can go right here.
        meanrain=mean(value,na.rm=TRUE),
        n_zero=sum(value==0,na.rm=TRUE),
        n_overflow=sum(value>300,na.rm=TRUE)
  )
}

ldply(.data=all_sched_melt,.fun=trt_summaries)

## next step: extract interesting infos from each line:
## is there any reason why sticking them all together would be bad?
do.call(rbind,all_schedules)

sapply(all_schedules,ncol)
sites

str(all_schedules[[1]])
lapply(all_schedules,names)

lapply(all_schedules,function(x){
  unique(x[,grepl("mu",names(x))])
}
)

lapply(all_schedules,
       function(x){
         unique(x[,grepl('\\.k|^k$',names(x))])
       }
)
