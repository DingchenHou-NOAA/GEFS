#!/bin/ksh
#####################################################################
echo "-----------------------------------------------------"
echo " Script: gefs_prdgen_lowres.sh" 
echo " "
echo " Purpose - Perform interpolation and GRIB2 conversion"
echo "           on master GRIB files to 2.5x2.5 degree"
echo "           for one member and one time step."
echo "           Move posted files to /com"
echo "           Alert posted files to DBNet"
echo " "
echo " History - "
echo "    Wobus   - 8/28/07 - New "
echo "    Wobus   - 7/30/10 - exclude 180-192hr products"
echo "-----------------------------------------------------"
#####################################################################
set -xa

anlflag=$anlflag
ffhr=$ffhr
fhr=$fhr

gefsmachine=wcoss  # WCOSS Temporary

export WGRIB=/nwprod/util/exec/wgrib
export GRBIDX=/nwprod/util/exec/grbindex
export COPYGB=/nwprod/util/exec/copygb
export WGRIB2=/nwprod/util/exec/wgrib2

export ENSADD=$USHgefs/global_ensadd.sh
export CNVGRIB=/nwprod/util/exec/cnvgrib

echo settings in $0 gefsmachine=$gefsmachine
echo settings in $0 WGRIB=$WGRIB
echo settings in $0 GRBIDX=$GRBIDX
echo settings in $0 ENSADD=$ENSADD
echo settings in $0 COPYGB=$COPYGB
echo settings in $0 CNVGRIB=$CNVGRIB
echo settings in $0 WGRIB2=$WGRIB2

R1=`echo $RUN|cut -c1-3`
R2=`echo $RUN|cut -c4-5`
case $R1 in
  (gec) if (( R2 == 0 )); then 
           (( e1 = 1 ))
	   (( e2 = 2 ))
	fi;;
  (gen) (( e1 = 2 ))
	(( e2 = R2 ));;
  (gep) (( e1 = 3 ))
	(( e2 = R2 ));;
  (*)   (( e1 = 0 ))
	(( e2 = 0 ))
	echo unrecognized RUN=$RUN R1=$R1 R2=$R2 ;;
esac

msg="Starting post for member=$member ffhr=$ffhr"
postmsg "$jlogfile" "$msg"

####################################
# Step I: create 2.5 x 2.5 pgrb
####################################

$COPYGB -g2 -i0 -x $COMIN/$cyc/master/$RUN.$cycle.master.grb$ffhr$cfsuffix pgbfile.$ffhr.2$cfsuffix
$ENSADD $e1 $e2 pgbfile.$ffhr.2$cfsuffix pgbifile.$ffhr.2$cfsuffix epgbfile.$ffhr.2$cfsuffix
if [[ "$addgrb1id" = "yes" ]]; then
   mv epgbfile.$ffhr.2$cfsuffix pgbfile.$ffhr.2$cfsuffix
   if [[ "$makegrb1i" = "yes" ]]; then
       $GRBIDX pgbfile.$ffhr.2$cfsuffix pgbifile.$ffhr.2$cfsuffix
   fi
fi
echo `date` pgrba 2.5x2.5 grbindex $ffhr completed

if  (( fhr == 0 ))
then
  hsuffix="00"
else
  hsuffix="hh"
fi

excludestring='180-192hr'

#######################################
# Step II: Create 2.5x2.5 PGRBA files
#######################################
if [[ -s $COMOUT/$cyc/pgrbalr/${RUN}.${cycle}.pgrba$ffhr.2$cfsuffix ]] && \
   [[ -s $COMOUT/$cyc/pgrbalr/${RUN}.${cycle}.pgrbai$ffhr.2$cfsuffix ]] && \
   [[ $overwrite = no ]]; then
     echo `date` 2.5x2.5 pgrbb processing skipped for $RUN $ffhr
else
   parmlist=$PARMgefs/gefs_pgrba_f${hsuffix}.parm
   set +x
   $WGRIB -s pgbfile.$ffhr.2$cfsuffix | \
       grep -F -f $parmlist | \
       grep -v -F $excludestring | \
       $WGRIB pgbfile.$ffhr.2$cfsuffix -s -grib -i -o pgbafile.$ffhr.2$cfsuffix
   if [[ x$fhoroglist != x ]]; then
      for fhorog in $fhoroglist
      do
	if (( fhr == fhorog )); then
	  $WGRIB -s pgbfile.$ffhr.2$cfsuffix | grep 'HGT:sfc' | $WGRIB pgbfile.$ffhr.2$cfsuffix -i -grib -append -o pgbafile.$ffhr.2$cfsuffix
	fi
      done
   fi
   set -x
$GRBIDX pgbafile.$ffhr.2$cfsuffix pgbaifile.$ffhr.2$cfsuffix
fi

#######################################
# Step III: Create 2.5x2.5 PGRBB files
#######################################
if [[ -s $COMOUT/$cyc/pgrbblr/${RUN}.${cycle}.pgrbb$ffhr.2$cfsuffix ]] && \
   [[ -s $COMOUT/$cyc/pgrbblr/${RUN}.${cycle}.pgrbbi$ffhr.2$cfsuffix ]] && \
   [[ $overwrite = no ]]; then
     echo `date` 2.5x2.5 pgrbb processing skipped for $RUN $ffhr
else
   parmlist=$PARMgefs/gefs_pgrbb_f${hsuffix}.parm
   set +x
   $WGRIB -s pgbfile.$ffhr.2$cfsuffix | \
       grep -F -f $parmlist | \
       grep -v -F $excludestring | \
       $WGRIB pgbfile.$ffhr.2$cfsuffix -s -grib -i -o pgbbfile.$ffhr.2$cfsuffix
   $GRBIDX pgbbfile.$ffhr.2$cfsuffix pgbbifile.$ffhr.2$cfsuffix
   set -x
fi

if test "$SENDCOM" = 'YES'
then
  #
  # Save Pressure GRIB/Index files
  #
  mv pgbafile.$ffhr.2$cfsuffix $COMOUT/$cyc/pgrbalr/${RUN}.${cycle}.pgrba$ffhr.2$cfsuffix
                      testfile=$COMOUT/$cyc/pgrbalr/${RUN}.${cycle}.pgrba$ffhr.2$cfsuffix
          if [[ ! -s $testfile ]]; then
            msg="FATAL ERROR: $testfile WAS NOT WRITTEN"
            echo "`date`    $msg"
            postmsg "$jlogfile" "$msg"
            export err=1
            err_chk
          fi
  mv pgbbfile.$ffhr.2$cfsuffix $COMOUT/$cyc/pgrbblr/${RUN}.${cycle}.pgrbb$ffhr.2$cfsuffix
                      testfile=$COMOUT/$cyc/pgrbblr/${RUN}.${cycle}.pgrbb$ffhr.2$cfsuffix
          if [[ ! -s $testfile ]]; then
            msg="FATAL ERROR: $testfile WAS NOT WRITTEN"
            echo "`date`    $msg"
            postmsg "$jlogfile" "$msg"
            export err=1
            err_chk
          fi
  if [[ "$makegrb1i" = "yes" ]]; then
     mv pgbaifile.$ffhr.2$cfsuffix $COMOUT/$cyc/pgrbalr/${RUN}.${cycle}.pgrbai$ffhr.2$cfsuffix
			  testfile=$COMOUT/$cyc/pgrbalr/${RUN}.${cycle}.pgrbai$ffhr.2$cfsuffix
          if [[ ! -s $testfile ]]; then
            msg="FATAL ERROR: $testfile WAS NOT WRITTEN"
            echo "`date`    $msg"
            postmsg "$jlogfile" "$msg"
            export err=1
            err_chk
          fi
     mv pgbbifile.$ffhr.2$cfsuffix $COMOUT/$cyc/pgrbblr/${RUN}.${cycle}.pgrbbi$ffhr.2$cfsuffix
			  testfile=$COMOUT/$cyc/pgrbblr/${RUN}.${cycle}.pgrbbi$ffhr.2$cfsuffix
          if [[ ! -s $testfile ]]; then
            msg="FATAL ERROR: $testfile WAS NOT WRITTEN"
            echo "`date`    $msg"
            postmsg "$jlogfile" "$msg"
            export err=1
            err_chk
          fi
  fi

  ######################################################################################
  # Send DBNet alerts for PGBA and PGBA2 at 6 hour increments for all forecast hours
  # Do for 00, 06, 12, and 18Z cycles.
  ######################################################################################
  if test "$SENDDBN" = 'YES' -a "$NET" = 'gens' -a ` expr $cyc % 6 ` -eq 0
  then
    if test `echo $RUN | cut -c1-2` = "ge"
    then
      MEMBER=`echo $RUN | cut -c3-5 | tr '[a-z]' '[A-Z]'`
      if test "$DO_LOW_RES" = 'YES' -a ` expr $fhr % 6 ` -eq 0 -a ! -n "$cfsuffix"
      then
        $DBNROOT/bin/dbn_alert MODEL ENS_PGBA2_$MEMBER $job $COMOUT/$cyc/pgrbalr/${RUN}.${cycle}.pgrba$ffhr.2$cfsuffix
      fi
    fi
  fi

  ######################################################################################
  # Send DBNet alerts for PGBB at 6 hour increments for forecast hours 0 - 84 and
  # for PGBB2 at 6 hour increments for forecast hours 90 through 384.
  # Do for 00 and 12Z cycles.
  ######################################################################################

  if test "$SENDDBN" = 'YES' -a "$NET" = 'gens' -a ` expr $cyc % 12 ` -eq 0
  then
    if test `echo $RUN | cut -c1-2` = "ge"
    then
      MEMBER=`echo $RUN | cut -c3-5 | tr '[a-z]' '[A-Z]'`
      if test "$DO_LOW_RES" = 'YES' -a ` expr $fhr % 6 ` -eq 0 -a $fhr -ge 90 -a ! -n "$cfsuffix"
      then
        $DBNROOT/bin/dbn_alert MODEL ENS_PGBB2_$MEMBER $job $COMOUT/$cyc/pgrbblr/${RUN}.${cycle}.pgrbb$ffhr.2$cfsuffix
      fi
    fi
  fi
fi

  case $gefsmachine in
    (wcoss)
      fmakegb=1
    ;;
    (zeus)
      fmakegb=0
    ll
  esac
if (( fmakegb == 1 )); then
#DHOU 03/23/2012, skip grib2 files for ZEUS
#########################################
# Step IV: Create the 2.5x2.5 GRIB2 files
########################################
if [[ -s $COMOUT/$cyc/pgrb2alr/${RUN}.${cycle}.pgrb2a$ffhr.2$cfsuffix ]] && \
   [[ -s $COMOUT/$cyc/pgrb2alr/${RUN}.${cycle}.pgrb2ai$ffhr.2$cfsuffix ]] && \
   [[ $overwrite = no ]]; then
   echo `date` 2.5x2.5 pgrb2a processing skipped for $RUN $ffhr
else
  FILEALR=$COMIN/$cyc/pgrbalr/${RUN}.${cycle}.pgrba$ffhr.2$cfsuffix

  $CNVGRIB -g12 -p40 $FILEALR pgb2a.$ffhr.2$cfsuffix
  $WGRIB2 -s pgb2a.$ffhr.2$cfsuffix >pgb2a.$ffhr.2${cfsuffix}.idx

  if test "$SENDCOM" = 'YES'
  then
    #
    # Save Pressure GRIB/Index files
    #
    mv pgb2a.$ffhr.2$cfsuffix $COMOUT/$cyc/pgrb2alr/${RUN}.${cycle}.pgrb2a$ffhr.2$cfsuffix
		     testfile=$COMOUT/$cyc/pgrb2alr/${RUN}.${cycle}.pgrb2a$ffhr.2$cfsuffix
          if [[ ! -s $testfile ]]; then
            msg="FATAL ERROR: $testfile WAS NOT WRITTEN"
            echo "`date`    $msg"
            postmsg "$jlogfile" "$msg"
            export err=1
            err_chk
          fi
    mv pgb2a.$ffhr.2${cfsuffix}.idx $COMOUT/$cyc/pgrb2alr/${RUN}.${cycle}.pgrb2a$ffhr.2${cfsuffix}.idx
			   testfile=$COMOUT/$cyc/pgrb2alr/${RUN}.${cycle}.pgrb2a$ffhr.2${cfsuffix}.idx
          if [[ ! -s $testfile ]]; then
            msg="FATAL ERROR: $testfile WAS NOT WRITTEN"
            echo "`date`    $msg"
            postmsg "$jlogfile" "$msg"
            export err=1
            err_chk
          fi

    if test "$SENDDBN" = 'YES'
    then
      if test "$NET" = 'gens'
      then
        if test `echo $RUN | cut -c1-2` = "ge" -a ! -n "$cfsuffix"
        then
          MEMBER=`echo $RUN | cut -c3-5 | tr '[a-z]' '[A-Z]'`
          $DBNROOT/bin/dbn_alert MODEL ENS_PGB2A2_$MEMBER $job $COMOUT/$cyc/pgrb2alr/${RUN}.${cycle}.pgrb2a$ffhr.2$cfsuffix
          $DBNROOT/bin/dbn_alert MODEL ENS_PGB2A2_${MEMBER}_WIDX $job \
                $COMOUT/$cyc/pgrb2alr/${RUN}.${cycle}.pgrb2a$ffhr.2${cfsuffix}.idx
        fi
      fi
    fi
  fi
fi


if [[ -s $COMOUT/$cyc/pgrb2blr/${RUN}.${cycle}.pgrb2b$ffhr.2$cfsuffix ]] && \
   [[ -s $COMOUT/$cyc/pgrb2blr/${RUN}.${cycle}.pgrb2bi$ffhr.2$cfsuffix ]] && \
   [[ $overwrite = no ]]; then
   echo `date` 2.5x2.5 pgrb2b processing skipped for $RUN $ffhr
else

  FILEBLR=$COMIN/$cyc/pgrbblr/${RUN}.${cycle}.pgrbb$ffhr.2$cfsuffix

  $CNVGRIB -g12 -p40 $FILEBLR pgb2bfile.$ffhr.2$cfsuffix
  $WGRIB2 -s pgb2bfile.$ffhr.2$cfsuffix >pgb2bfile.$ffhr.2${cfsuffix}.idx

  if test "$SENDCOM" = 'YES'
  then
    #
    # Save Pressure GRIB/Index files
    #
    mv pgb2bfile.$ffhr.2$cfsuffix $COMOUT/$cyc/pgrb2blr/${RUN}.${cycle}.pgrb2b$ffhr.2$cfsuffix
			 testfile=$COMOUT/$cyc/pgrb2blr/${RUN}.${cycle}.pgrb2b$ffhr.2$cfsuffix
          if [[ ! -s $testfile ]]; then
            msg="FATAL ERROR: $testfile WAS NOT WRITTEN"
            echo "`date`    $msg"
            postmsg "$jlogfile" "$msg"
            export err=1
            err_chk
          fi
    mv pgb2bfile.$ffhr.2${cfsuffix}.idx $COMOUT/$cyc/pgrb2blr/${RUN}.${cycle}.pgrb2b$ffhr.2${cfsuffix}.idx
                               testfile=$COMOUT/$cyc/pgrb2blr/${RUN}.${cycle}.pgrb2b$ffhr.2${cfsuffix}.idx
          if [[ ! -s $testfile ]]; then
            msg="FATAL ERROR: $testfile WAS NOT WRITTEN"
            echo "`date`    $msg"
            postmsg "$jlogfile" "$msg"
            export err=1
            err_chk
          fi

    if test "$SENDDBN" = 'YES'
    then
      if test "$NET" = 'gens'
      then
	if test `echo $RUN | cut -c1-2` = "ge" -a ! -n "$cfsuffix"
	then
	  MEMBER=`echo $RUN | cut -c3-5 | tr '[a-z]' '[A-Z]'`
	  $DBNROOT/bin/dbn_alert MODEL ENS_PGB2B2_$MEMBER $job $COMOUT/$cyc/pgrb2blr/${RUN}.${cycle}.pgrb2b$ffhr.2$cfsuffix
	  $DBNROOT/bin/dbn_alert MODEL ENS_PGB2B2_${MEMBER}_WIDX $job \
             $COMOUT/$cyc/pgrb2blr/${RUN}.${cycle}.pgrb2b$ffhr.2${cfsuffix}.idx
	fi
      fi
    fi
  fi
fi

fi #(0=1 foe ZEUS, skip grib2 files)
####################################
# Step V: Save forecasts to /nwges
####################################
if test "$SAVEGES" = "YES" -a $fhr -le 15
then
   cp $COMOUT/$cyc/sfcsig/${RUN}.t${cyc}z.s$ffhr$cfsuffix $GESdir/${RUN}.${cycle}.s$ffhr$cfsuffix
   cp $COMOUT/$cyc/sfcsig/${RUN}.t${cyc}z.b$ffhr$cfsuffix $GESdir/${RUN}.${cycle}.b$ffhr$cfsuffix
   msg="Guess files for fcst hour $fhr copied to $GESdir"
   postmsg "$jlogfile" "$msg"
fi
echo `date` sf and bf copied to nwges $ffhr completed

##########################################
# Step VI: Create sigstats in non-nco run
##########################################
#DHOU 04/14/2012 temporly commented out this bloc as sigstat is not found
#if [[ $envir != prod ]]; then
#  if [[ $envir != para ]]; then
#    if [[ $envir != test ]]; then
#      sigfilename=${RUN}.t${cyc}z.s$ffhr$cfsuffix
#      $EXECgefs/sigstat $COMIN/$cyc/sfcsig/$sigfilename >$COMOUT/$cyc/stats/sigstat.$sigfilename
#    fi
#  fi
#fi
    
########################################################
echo `date` $sname $member $partltr $cfsuffix $fsuffix 2.5x2.5 GRIB end on machine=`uname -n`
msg='ENDED NORMALLY.'
postmsg "$jlogfile" "$msg"

################## END OF SCRIPT #######################
