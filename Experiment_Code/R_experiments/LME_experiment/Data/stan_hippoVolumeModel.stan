data {
  int<lower=1>              Ni;   // number of individuals 
  int<lower=1>              Nij;  // number of observations
  int<lower=1>              Nk;   // number of regions
  int<lower=1>              Na1;  // number of subjects with multiple observations
  
  matrix[Nij, Nk]           Y;          // design matrix for each region
  vector[Nij]               timePoints; // time point
  vector[Nij]               m;          // bool = 1 if multiple observations from individual i
  
  int                       ids[Nij];       // vector of each individual id      
  int                       slopeIds[Na1];  // each subject with multiple observations has own number in {1, ..., Na1}
}

parameters {
  vector<lower=0>[Nk]    sigma; 

  vector[Nk]             alpha_0;         
  vector[Nk]             alpha_1;         

  vector[Ni]             alpha_0_intercept[Nk];    
  vector[Na1]            alpha_1_intercept[Nk];    

  vector<lower=0>[Nk]    tau_0;
  vector<lower=0>[Nk]    tau_1;
}

model {
  vector[Nij]        alpha_0_intercept_s[Nk];
  vector[Nij]        alpha_1_intercept_s[Nk];
  int                counter;

  counter = 1;

  alpha_0 ~ normal( 0, 10 );
  alpha_1 ~ normal( 0, 10 );
  tau_0   ~ cauchy( 0,  5 );
  tau_1   ~ cauchy( 0,  5 );
  sigma   ~ cauchy( 0,  5 ); 
  
  for( k in 1:Nk )
    {
    alpha_0_intercept[k] ~ normal( alpha_0[k], tau_0[k] );
    alpha_1_intercept[k] ~ normal( alpha_1[k], tau_1[k] );
    
    for( ij in 1:Nij )
      {
      alpha_0_intercept_s[k][ij] = alpha_0_intercept[k][ids[ij]];
      alpha_1_intercept_s[k][ij] = alpha_1_intercept[k][ids[ij]];
	  alpha_1_intercept_s[k][ij] = alpha_1_intercept[k][slopeIds[Ni]];

      }
    }
  
  for( k in 1:Nk ) 
    { 
    col( Y, k ) ~ normal( 
      alpha_0_intercept_s[k] + alpha_1_intercept_s[k] .* timePoints, sigma[k] );
    }
}

generated quantities {
  vector[Nk]  var_ratio;
  vector[Nk]  var_ratio_experimental;
  
  var_ratio = tau_0 ./ sigma;
  var_ratio_experimental = ( tau_0 + tau_1 ) ./ sigma;
}

