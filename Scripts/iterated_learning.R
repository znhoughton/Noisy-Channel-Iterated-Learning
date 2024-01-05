#two functions included here: iterated_learning which is a parallelized iterated learning model, and iterated_learning_not_parallelized which, unsurprisingly, is the original iterated learning model we created without parallelization.

iterated_learning = function(n_gen, n_sims, p_theta, N, prior_mu, nu, p_noise, prior_prob_noise, last_gen_only = F) { #set last_gen_only to T if you wish to save memory and only care about the last generation.
  #mu_df = tibble(posterior_mu = numeric(), generation = numeric(), estimated_p_theta = numeric())
  
  sim_function = function() {
    p_new_theta = p_theta
    map_dfr(1:n_gen, ~{
      #if (. %% 100 == 0) {
      # print(sprintf('current generation is: %s', .))
      #}
      generation = .
      posterior_mu = noisy_channel_learning_prod_noise(p_theta = p_new_theta, N = N, prior_mu = prior_mu, nu = nu, p_noise = p_noise, prior_prob_noise = prior_prob_noise)
      
      if(last_gen_only == F) {
        result = tibble(posterior_mu = posterior_mu, generation = generation, estimated_p_theta = p_new_theta)
        p_new_theta <<- posterior_mu #need to use the operator <<- to update p_new_theta on a global scope
      
        return(result)
      }
      else{
        p_new_theta <<- posterior_mu #need to use the operator <<- to update p_new_theta on a global scope
        if(generation == n_gen) {
          result = tibble(posterior_mu = posterior_mu, generation = generation, estimated_p_theta = p_new_theta)
        }
      }
    })
  }
  
  mu_df <- future_map_dfr(1:n_sims, ~sim_function())
  
  return(mu_df)
}

iterated_learning_not_parallelized = function(n_gen, n_sims, p_theta, N, prior_mu, nu, p_noise, prior_prob_noise) { #this version is included to make sure that the parallelized version yields similar results to this one, since underlyingly they should be the same
  mu_df = data.frame(matrix(ncol = 3, nrow = 0))
  colnames(mu_df) = c('posterior_mu', 'generation', 'estimated p_theta')
  for (i in 1:n_sims) {
    #if(i %% 5 == 0) {
    #print(sprintf('current simulation number: %s', i))
    #print(sprintf('current frequency value: %s', N))
    #print(i)
    #print(N)
    
    #}
    
    p_new_theta = p_theta  
    
    for(i in 1:n_gen) {
      if(i %% 100 == 0) {
        #print(sprintf('current generation is: %s', i))
      }
      generation = i
      posterior_mu = noisy_channel_learning_prod_noise(p_theta = p_new_theta, N=N, prior_mu = prior_mu, nu=nu, p_noise=p_noise, prior_prob_noise=prior_prob_noise)
      mu_df[nrow(mu_df) + 1,] = c(posterior_mu, generation, p_new_theta)
      p_new_theta = posterior_mu
    }
  }
  
  return(mu_df)
  
}
