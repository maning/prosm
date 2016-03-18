while read i ;do                                                                                                                                                                           
   x=$((i-${i#?}))                                                                                                                                                                         
   echo $((${x%%0*}+1))${x#?}                                                                                                                                                              
done
