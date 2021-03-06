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

import edu.stanford.nlp.dcoref.CorefChain.CorefMention;

public class PipelineCorefMention extends PipelineItem {
   private int startIndex = 0;
   private int endIndex   = 0;
   private int headIndex  = 0;
   private int sentNum    = 0;
   
   private PipelineTokenList tokens;
   private PipelineToken     headToken;
   
   public int getStartIndex() { return startIndex; }
   public int getEndIndex()   { return endIndex; }
   public int getHeadIndex()  { return headIndex; }
   public int getSentNum()    { return sentNum; }
   
   public PipelineTokenList getTokens()    { return tokens; }
   public PipelineToken     getHeadToken() { return headToken; }

   public void setTokens(PipelineTokenList tl) { tokens = tl; }
   public void setHeadToken(PipelineToken t)   { headToken = t; }
   
   public PipelineCorefMention() {}
   
   public PipelineCorefMention(int start, int end, int head, int sent) {
      this.startIndex = start;
      this.endIndex   = end;
      this.headIndex  = head;
      this.sentNum    = sent;
   }
   
   public static PipelineCorefMention fromMention(CorefMention ment) {
      return new PipelineCorefMention(
        ment.startIndex - 1,
        ment.endIndex   - 1,
        ment.headIndex  - 1,
        ment.sentNum    - 1
      );
   }
   
   @Override
   public String toString() {
      return toCompactString() 
        + " [@" + sentNum + ":" + startIndex + "-" + endIndex + "]";
   }
   
   @Override
   public String toCompactString() {
      String out = "";
      for (PipelineToken t: tokens) {
         if (out.length() > 0)
            out += " ";
         out += t.getWord();
      }
      return out;
   }
}
