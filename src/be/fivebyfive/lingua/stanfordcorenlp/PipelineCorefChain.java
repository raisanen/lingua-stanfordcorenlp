/*
 * Lingua::StanfordCoreNLP
 * Copyright © 2011-2013 Kalle Räisänen.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see L<http://www.gnu.org/licenses/>.
 */
package be.fivebyfive.lingua.stanfordcorenlp;

public class PipelineCorefChain {
   private PipelineCorefMentionList mentions = new PipelineCorefMentionList();
   private boolean                  multiSentence = false;
   private PipelineCorefMention     representativeMention;
   
   public PipelineCorefMentionList  getMentions() { return mentions; }
   public void addMention(PipelineCorefMention c) {
      if (!multiSentence) {
         for (PipelineCorefMention m: mentions) {
            if (m.getSentNum() != c.getSentNum()) {
               multiSentence = true;
               break;
            }
         }
      }
      mentions.add(c);
   }
   public boolean isMultiSentence() { return multiSentence; }
   public PipelineCorefMention getRepresentativeMention() {
      return representativeMention;
   }
   public void setRepresentativeMention(PipelineCorefMention cr) {
      representativeMention = cr;
   }

   public PipelineCorefChain() { }
   
   @Override 
   public String toString() { 
      return 
        (representativeMention != null
              ? representativeMention.toString() + " => "
              : "") 
        + mentions.joinList(" <=> ");
   }
}
