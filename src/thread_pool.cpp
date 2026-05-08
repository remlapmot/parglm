#include "thread_pool.h"
#include <memory>

join_threads::join_threads(std::vector<std::thread>& threads_):
  threads(threads_)
{}

join_threads::~join_threads()
{
  for(unsigned long i=0;i<threads.size();++i)
  {
    threads[i].join();
  }
}

static unsigned            s_pool_n_threads = 0;
static std::unique_ptr<thread_pool> s_persistent_pool;

thread_pool& get_persistent_pool(unsigned n_threads) {
  if (!s_persistent_pool || s_pool_n_threads != n_threads) {
    s_persistent_pool.reset(); /* destroy (joins threads) before creating */
    s_persistent_pool.reset(new thread_pool(n_threads));
    s_pool_n_threads = n_threads;
  }
  return *s_persistent_pool;
}
