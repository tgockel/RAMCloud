/* Copyright (c) 2009-2016 Stanford University
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR(S) DISCLAIM ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL AUTHORS BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#ifndef RAMCLOUD_COREPOLICYRAMCLOUD_H
#define RAMCLOUD_COREPOLICYRAMCLOUD_H

#include "Arachne/CorePolicy.h"

#define BASE_THREAD_CLASS 0
#define DISPATCH_THREAD_CLASS 1
#define DISPATCH_HT_THREAD_CLASS 2

extern CorePolicy* corePolicyRamCloud;

class CorePolicyRamCloud : public CorePolicy {
  public:
    /** Constructor and destructor for CorePolicyRamCloud. */
    CorePolicyRamCloud() : CorePolicy() {}

    void addCore(int coreId);

    /* Thread class for the dispatch thread. Gets a core to itself */
    threadClass_t dispatchClass = DISPATCH_THREAD_CLASS;
    /* Thread class used to protect the dispatch thread's hypertwin. */
    threadClass_t dispatchHTClass = DISPATCH_HT_THREAD_CLASS;
    /* Cores occupied by the dispatch thread and its hypertwin. */
    int numNecessaryCores = 0;
   private:
    int dispatchHyperTwin = -1;
    int getHyperTwin(int coreId);
};

#endif // !RAMCLOUD_COREPOLICYRAMCLOUD_H