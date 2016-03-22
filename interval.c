/*1:*/
#line 109 "./interval.w"

#include <stdio.h> 
#include <stdlib.h> 

/*2:*/
#line 138 "./interval.w"


static const int dia_to_chrom[]= {0,2,4,5,7,9,11};


static const int accidental_code[]= {-2,-1,0,1,2};
static const char accidental_name[]= {'B','b','n','s','X'};

static const int interval_quality_code[]= {-1,-1,0,0,1};
static const char interval_quality_name[]= {'d','m','M','P','a'};

/*26:*/
#line 491 "./interval.w"

static const char*error[]= {
"There must be six arguments after the program name.\n"
"Usage: interval <pitch class> <accidental> <octave> <+ or -> <interval quality> <interval degree>\n",
"Incorrect pitch name '%s'. Should be letter A-G.\n",
"Accidental can only be 'B', 'b', 'n', 's', or 'X'. You entered '%s'.\n",
"Octave number must be between 0 and 20. You entered '%s'.\n",
"Operator must be + or -. You entered '%s'.\n",
"Interval quality can only be 'd', 'm', 'M', 'P', or 'a'. You entered '%s'.\n",
"Interval degree must be between 1 and 70. You entered '%s'.\n",
"Mismatch of interval quality and degree. 'P' not allowed with imperfect intervals; 'm', 'M' not allowed with perfect.\n",
"Result octave cannot be lower than 0. Calculation stopped.\n",
"Computation error: Result pitchclass is out of range.\n",
"Computation error: End accidental is out of range.\n"
};
static const enum{
ERROR_ARGNUM,ERROR_PITCH,ERROR_ACCIDENTAL,ERROR_OCTAVE,
ERROR_OPERATOR,ERROR_INTERVAL_QUALITY,ERROR_INTERVAL_DEGREE,
ERROR_MISMATCH_INTERVAL_QUALITY,ERROR_OCTAVE_RANGE,
ERROR_ENDPITCH_RANGE,ERROR_ENDACCIDENTAL_RANGE
}error_msg;

/*:26*/
#line 149 "./interval.w"


/*:2*/
#line 113 "./interval.w"

/*3:*/
#line 154 "./interval.w"

typedef enum{FALSE,TRUE}boolean;
boolean found;
boolean perfect_interval;

/*:3*/
#line 114 "./interval.w"

/*5:*/
#line 164 "./interval.w"

void convert_from_base_ten(int base,int input,int*main_tens,int*main_ones);

/*:5*//*7:*/
#line 187 "./interval.w"

int convert_to_base_ten(int base,int multiples,int ones);

/*:7*//*27:*/
#line 515 "./interval.w"

void exit_error(int msg_code,char*arg);

/*:27*/
#line 115 "./interval.w"


int main(int argc,char*argv[])
{
/*9:*/
#line 220 "./interval.w"

int i;
int start_pitchclass;
int start_accidental;
int start_octave;
int operator;
int interval_quality;
char interval_quality_name_in;
int interval_dia;

/*:9*//*18:*/
#line 342 "./interval.w"

int interval_octaves;

int interval_steps_dia;


/*:18*//*20:*/
#line 398 "./interval.w"

int start_abs_pitch_dia;
int end_abs_pitch_dia;
int end_pitchclass;
int end_octave;

/*:20*//*22:*/
#line 422 "./interval.w"

int end_accidental;
int start_abs_pitch_chrom;
int end_abs_pitch_chrom;
int end_base_pitch_chrom;

int interval_chrom;

/*:22*//*24:*/
#line 469 "./interval.w"

char end_pitchclass_symb;
char end_accidental_symb;

/*:24*/
#line 119 "./interval.w"

/*10:*/
#line 237 "./interval.w"

/*11:*/
#line 249 "./interval.w"

if(argc!=7){
exit_error(ERROR_ARGNUM,NULL);
}

/*:11*/
#line 238 "./interval.w"

/*12:*/
#line 258 "./interval.w"

if(argv[1][1]!='\0'||argv[1][0]<'A'||argv[1][0]> 'G'){
exit_error(ERROR_PITCH,argv[1]);
}
start_pitchclass= (int)argv[1][0]-'C';
if(start_pitchclass<0){
start_pitchclass+= 7;
}

/*:12*/
#line 239 "./interval.w"

/*13:*/
#line 270 "./interval.w"

if(argv[2][1]!='\0'){
exit_error(ERROR_ACCIDENTAL,argv[2]);
}
for(i= 0,found= FALSE;accidental_name[i]!='\0';++i){
if(argv[2][0]==accidental_name[i]){
found= TRUE;
start_accidental= accidental_code[i];
break;
}
}
if(found==FALSE){
exit_error(ERROR_ACCIDENTAL,argv[2]);
}

/*:13*/
#line 240 "./interval.w"

/*14:*/
#line 287 "./interval.w"

sscanf(argv[3],"%d",&start_octave);
if(start_octave<0||start_octave> 20){
exit_error(ERROR_OCTAVE,argv[3]);
}

/*:14*/
#line 241 "./interval.w"

/*15:*/
#line 295 "./interval.w"

if(argv[4][1]!='\0'){
exit_error(ERROR_OPERATOR,argv[4]);
}else{
switch(argv[4][0]){
case'-':
operator= -1;
break;
case'+':
operator= 1;
break;
default:
exit_error(ERROR_OPERATOR,argv[4]);
}
}

/*:15*/
#line 242 "./interval.w"

/*16:*/
#line 314 "./interval.w"

if(argv[5][1]!='\0'){
exit_error(ERROR_INTERVAL_QUALITY,argv[5]);
}
for(i= 0,found= FALSE;interval_quality_name[i]!='\0';++i){
if(argv[5][0]==interval_quality_name[i]){
found= TRUE;
interval_quality_name_in= argv[5][0];
interval_quality= interval_quality_code[i];
break;
}
}
if(found==FALSE){
exit_error(ERROR_INTERVAL_QUALITY,argv[5]);
}

/*:16*/
#line 243 "./interval.w"

/*17:*/
#line 333 "./interval.w"

sscanf(argv[6],"%d",&interval_dia);
if(interval_dia<1||interval_dia> 70){
exit_error(ERROR_INTERVAL_DEGREE,argv[6]);
}
--interval_dia;

/*:17*/
#line 244 "./interval.w"

/*19:*/
#line 358 "./interval.w"

interval_octaves= interval_steps_dia= 0;
convert_from_base_ten(7,interval_dia,&interval_octaves,&interval_steps_dia);

switch(interval_steps_dia){
case 0:
case 3:
case 4:
perfect_interval= TRUE;
break;
default:
perfect_interval= FALSE;
}
if(perfect_interval==TRUE){
switch(interval_quality_name_in){
case'm':
case'M':
exit_error(ERROR_MISMATCH_INTERVAL_QUALITY,NULL);
break;
default:
;
}
}else{
switch(interval_quality_name_in){
case'P':
exit_error(ERROR_MISMATCH_INTERVAL_QUALITY,NULL);
break;
case'd':
--interval_quality;
break;
default:
;
}
}




/*:19*/
#line 245 "./interval.w"


/*:10*/
#line 120 "./interval.w"

/*21:*/
#line 407 "./interval.w"

start_abs_pitch_dia= convert_to_base_ten(7,start_octave,start_pitchclass);
end_abs_pitch_dia= start_abs_pitch_dia+operator*interval_dia;
end_pitchclass= end_octave= 0;
convert_from_base_ten(7,end_abs_pitch_dia,&end_octave,&end_pitchclass);

if(end_octave<0){
exit_error(ERROR_OCTAVE_RANGE,NULL);
}
if(end_pitchclass<0||end_pitchclass> 6){
exit_error(ERROR_ENDPITCH_RANGE,NULL);
}

/*:21*/
#line 121 "./interval.w"

/*23:*/
#line 447 "./interval.w"

start_abs_pitch_chrom= 
convert_to_base_ten(12,start_octave,dia_to_chrom[start_pitchclass])
+start_accidental;

interval_chrom= 
convert_to_base_ten(12,interval_octaves,
dia_to_chrom[interval_steps_dia])+interval_quality;

end_abs_pitch_chrom= start_abs_pitch_chrom+operator*interval_chrom;

end_base_pitch_chrom= 
convert_to_base_ten(12,end_octave,
dia_to_chrom[end_pitchclass]);

end_accidental= end_abs_pitch_chrom-end_base_pitch_chrom;

/*:23*/
#line 122 "./interval.w"

/*25:*/
#line 475 "./interval.w"

end_accidental+= 2;
if(end_accidental<0||end_accidental> 4){
exit_error(ERROR_ENDACCIDENTAL_RANGE,NULL);
}
if(end_pitchclass> 4){
end_pitchclass-= 7;
}
end_pitchclass_symb= (char)(end_pitchclass+'C');
end_accidental_symb= accidental_name[end_accidental];

printf("%c %c %d\n",end_pitchclass_symb,end_accidental_symb,end_octave);

/*:25*/
#line 123 "./interval.w"

return(0);
}

/*:1*//*6:*/
#line 170 "./interval.w"

void convert_from_base_ten(int base,int input,int*main_tens,int*main_ones)
{
int tens,ones;
tens= 0;
ones= input;
while(ones> base){
ones-= base;
++tens;
}
*main_tens= tens;
*main_ones= ones;
return;
}

/*:6*//*8:*/
#line 192 "./interval.w"

int convert_to_base_ten(int base,int multiples,int ones)
{
int result;
result= base*multiples+ones;
return(result);
}


/*:8*//*28:*/
#line 521 "./interval.w"

void exit_error(int msg_code,char*arg)
{
fprintf(stderr,error[msg_code],arg);
exit(EXIT_FAILURE);
}

/*:28*/
