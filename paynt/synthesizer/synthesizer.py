from .statistic import Statistic

import logging
logger = logging.getLogger(__name__)


class Synthesizer:

    # if True, some subfamilies can be discarded and some holes can be generalized
    incomplete_search = False
    
    def __init__(self, quotient):
        self.quotient = quotient
        self.stat = Statistic(self)
        self.explored = 0
    
    @property
    def method_name(self):
        ''' to be overridden '''
        pass
    
    def synthesize(self, family = None):
        
        logger.info("Synthesis initiated.")
        self.stat.start()

        if family is None:
            family = self.quotient.design_space
        assignment = self.synthesize_assignment(family) # dalsi magie
        
        self.stat.finished(assignment)
        return assignment

    
    def synthesize_assignment(self,family):
        pass
    
    def print_stats(self):
        self.stat.print()
    
    def run(self):
        # self.quotient.specification.optimality.update_optimum(0.9)
        self.quotient.design_space.property_indices = self.quotient.specification.all_constraint_indices()
        assignment = self.synthesize(self.quotient.design_space) # v tomto kroku se deje magie
        print("")
        if assignment is not None:
            logger.info("Printing synthesized assignment below:")
            logger.info(assignment)
            dtmc = self.quotient.build_chain(assignment)
            mc_result = dtmc.check_specification(self.quotient.specification)
            logger.info("Double-checking specification satisfiability: {}".format(mc_result))
            if self.quotient.export_optimal_result:
                self.quotient.export_result(dtmc, mc_result)
        
        self.print_stats()
    
    def explore(self, family):
        self.explored += family.size

